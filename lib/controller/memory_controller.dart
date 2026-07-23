import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/live_sync_controller.dart';
import 'package:yaaram/controller/utils/database/database_service.dart';
import 'package:yaaram/model/memory_model/memory_comment_model.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/model/moments_filter.dart';
import 'package:yaaram/services/user_profile_service.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/services/cloudinary_service.dart';
import 'package:yaaram/services/firestore_memory_service.dart';

class MemoryController extends GetxController {
  final RxList<Memory> memories = <Memory>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;

  final DatabaseService _db = DatabaseService.instance;
  final FirestoreMemoryService _firestore = FirestoreMemoryService.instance;
  final CloudinaryService _cloudinary = CloudinaryService.instance;

  StreamSubscription<List<Memory>>? _firestoreSub;
  String? _activeCoupleId;
  bool _defaultsSeeded = false;

  AuthController get _auth => Get.find<AuthController>();

  bool get _useCloud => _auth.hasCouple && _auth.coupleId != null;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.profile, (_) => _restartSync());
    _restartSync();
  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  void _restartSync() {
    _firestoreSub?.cancel();
    _activeCoupleId = _auth.coupleId;

    if (_useCloud && _activeCoupleId != null) {
      _subscribeFirestore(_activeCoupleId!);
    } else {
      loadMemories();
    }
  }

  void _subscribeFirestore(String coupleId) {
    isLoading.value = true;
    _firestoreSub = _firestore.watchMemories(coupleId).listen(
      (cloudMemories) async {
        if (cloudMemories.isEmpty && !_defaultsSeeded) {
          _defaultsSeeded = true;
          await _loadDefaultMemories();
          return;
        }
        memories.value = cloudMemories;
        await _cacheToLocal(cloudMemories);
        isLoading.value = false;
      },
      onError: (e) {
        print('Firestore stream error: $e');
        loadMemories();
      },
    );
  }

  Future<void> _cacheToLocal(List<Memory> list) async {
    for (final memory in list) {
      try {
        final existing = await _db.getMemory(memory.id);
        if (existing == null) {
          final json = memory.toJson();
          json['createdAt'] = memory.date.millisecondsSinceEpoch;
          await _db.createMemoryFromJson(json);
        } else {
          await _db.updateMemory(memory);
        }
      } catch (_) {}
    }
  }

  Future<void> loadMemories() async {
    try {
      isLoading.value = true;
      final loadedMemories = await _db.getAllMemories();
      memories.value = loadedMemories;

      if (memories.isEmpty && !_useCloud) {
        await _loadDefaultMemories();
      }
    } catch (e) {
      print('Error loading memories: $e');
      Get.snackbar('Error', 'Failed to load memories: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _copyMediaToAppDirectory(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDir.path}/memories_media');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }
      final fileName = sourcePath.split(Platform.pathSeparator).last;
      final destPath = '${mediaDir.path}/$fileName';
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (e) {
      return sourcePath;
    }
  }

  Future<List<MediaFile>> _prepareMedia(List<MediaFile> files) async {
    if (await _isOnline() && _useCloud) {
      try {
        return await _cloudinary.uploadMediaFiles(files);
      } catch (e) {
        print('Cloudinary upload failed, using local: $e');
      }
    }

    final copied = <MediaFile>[];
    for (var media in files) {
      if (media.isRemote) {
        copied.add(media);
      } else {
        final newPath = await _copyMediaToAppDirectory(media.path);
        copied.add(media.copyWith(path: newPath));
      }
    }
    return copied;
  }

  Future<Memory?> addMemory(Memory memory) async {
    try {
      isSyncing.value = true;
      final mediaFiles = await _prepareMedia(memory.mediaFiles);
      final newId = DateTime.now().millisecondsSinceEpoch;
      final toSave = memory.copyWith(
        id: newId,
        mediaFiles: mediaFiles,
        createdBy: _auth.uid,
      );

      if (_useCloud && await _isOnline()) {
        try {
          await _firestore.createMemory(_auth.coupleId!, toSave, createdBy: _auth.uid);
        } catch (e) {
          final json = toSave.toJson();
          json['createdAt'] = DateTime.now().millisecondsSinceEpoch;
          await _db.createMemoryFromJson(json);
          await loadMemories();
        }
      } else {
        final json = toSave.toJson();
        json['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        await _db.createMemoryFromJson(json);
        await loadMemories();
      }

      final saved = memories.firstWhereOrNull((m) => m.id == newId) ?? toSave;
      Get.snackbar('Success', 'Memory saved to our love story',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      try {
        await Get.find<LiveSyncController>()
            .notifyPartnerOfMemory(saved.title);
      } catch (_) {}
      return saved;
    } catch (e) {
      print('Error adding memory: $e');
      Get.snackbar('Error', 'Failed to save memory: $e',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<bool> updateMemory(Memory updatedMemory) async {
    try {
      isSyncing.value = true;
      final mediaFiles = await _prepareMedia(updatedMemory.mediaFiles);
      final toSave = updatedMemory.copyWith(mediaFiles: mediaFiles);

      if (_useCloud && await _isOnline()) {
        await _firestore.updateMemory(_auth.coupleId!, toSave);
      } else {
        await _db.updateMemory(toSave);
        await loadMemories();
      }

      Get.snackbar('Success', 'Memory updated',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      return true;
    } catch (e) {
      print('Error updating memory: $e');
      Get.snackbar('Error', 'Failed to update memory',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> restoreMemory(int id) async {
    try {
      if (_useCloud && await _isOnline()) {
        await _firestore.restore(_auth.coupleId!, id);
      } else {
        await _db.restoreMemory(id);
        await loadMemories();
      }
      Get.snackbar('Restored', 'Memory has been restored',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to restore memory',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> permanentDeleteMemory(int id) async {
    try {
      if (_useCloud && await _isOnline()) {
        await _firestore.permanentDelete(_auth.coupleId!, id);
      } else {
        await _db.permanentDeleteMemory(id);
        await loadMemories();
      }
      Get.snackbar('Deleted', 'Memory permanently removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to permanently delete memory',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteMemory(int id) async {
    try {
      if (_useCloud && await _isOnline()) {
        await _firestore.softDelete(_auth.coupleId!, id);
      } else {
        await _db.deleteMemory(id);
        await loadMemories();
      }
      Get.snackbar('Deleted', 'Memory removed',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete memory',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final index = memories.indexWhere((m) => m.id == id);
      if (index == -1) return;
      final memory = memories[index];
      final updated = memory.copyWith(isFavorite: !memory.isFavorite);

      if (_useCloud && await _isOnline()) {
        await _firestore.updateMemory(_auth.coupleId!, updated);
      } else {
        await _db.updateMemory(updated);
        await loadMemories();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  List<Memory> discoverMemoriesFor(String uid, {String? partnerUid}) {
    return memories.where((m) {
      if (m.isDeleted) return false;
      if (m.hasUnseenNotesFrom(uid, partnerUid)) return true;

      // Partner-authored cards, or shared defaults (no createdBy).
      final author = m.createdBy;
      final isOwn = author != null && author.isNotEmpty && author == uid;
      if (isOwn) return false;
      return !m.viewedBy.contains(uid);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Memory> momentsMemoriesFor(
    String uid,
    String? partnerUid,
    MomentsFilter filter,
  ) {
    var list = memories.where((m) => !m.isDeleted).toList();
    switch (filter) {
      case MomentsFilter.together:
        list = list.where((m) => m.isTogetherMoment).toList();
      case MomentsFilter.mine:
        list = list
            .where((m) => m.createdBy == uid || m.createdBy == null)
            .toList();
      case MomentsFilter.partner:
        if (partnerUid != null) {
          list = list.where((m) => m.createdBy == partnerUid).toList();
        } else {
          list = [];
        }
      case MomentsFilter.saved:
        list = list
            .where((m) => m.isFavorite || m.isStarredBy(uid))
            .toList();
      case MomentsFilter.noted:
        list = list.where((m) => m.comments.isNotEmpty).toList();
      case MomentsFilter.all:
        break;
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<String?> partnerUid() async {
    final uid = _auth.uid;
    if (uid == null) return null;
    return UserProfileService.instance.getPartnerUid(uid);
  }

  Future<void> markDiscoverViewed(int id) async {
    final uid = _auth.uid;
    if (uid == null) return;
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final memory = memories[index];
    if (memory.viewedBy.contains(uid)) return;

    final viewedBy = [...memory.viewedBy, uid];
    final updated = memory.copyWith(viewedBy: viewedBy);

    if (_useCloud && await _isOnline()) {
      await _firestore.patchMemory(_auth.coupleId!, id, {'viewedBy': viewedBy});
    } else {
      memories[index] = updated;
      await _db.updateMemory(updated);
    }
  }

  /// Puts dismissed discover cards back into the stack for this user.
  Future<int> replayDiscoverMemories() async {
    final uid = _auth.uid;
    if (uid == null) return 0;

    final toReplay = memories
        .where((m) => !m.isDeleted && m.viewedBy.contains(uid))
        .toList(growable: false);
    if (toReplay.isEmpty) return 0;

    if (_useCloud && await _isOnline()) {
      await _firestore.clearViewedByForUser(
        _auth.coupleId!,
        uid,
        toReplay.map((m) => m.id),
      );
      // Optimistic local update until stream catches up.
      for (final memory in toReplay) {
        final index = memories.indexWhere((m) => m.id == memory.id);
        if (index == -1) continue;
        memories[index] = memory.copyWith(
          viewedBy: memory.viewedBy.where((id) => id != uid).toList(),
        );
      }
      memories.refresh();
    } else {
      for (final memory in toReplay) {
        final updated = memory.copyWith(
          viewedBy: memory.viewedBy.where((id) => id != uid).toList(),
        );
        await _db.updateMemory(updated);
      }
      await loadMemories();
    }
    return toReplay.length;
  }

  Future<void> toggleLikeMemory(int id) async {
    final uid = _auth.uid;
    if (uid == null) return;
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final memory = memories[index];
    final likedBy = List<String>.from(memory.likedBy);
    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }
    final updated = memory.copyWith(likedBy: likedBy);
    await _patchMemory(index, updated, {'likedBy': likedBy});
  }

  Future<void> likeDiscoverMemory(int id) async {
    final uid = _auth.uid;
    if (uid == null) return;
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final memory = memories[index];
    if (memory.likedBy.contains(uid)) {
      await markDiscoverViewed(id);
      return;
    }

    final likedBy = [...memory.likedBy, uid];
    final updated = memory.copyWith(likedBy: likedBy);

    if (_useCloud && await _isOnline()) {
      await _firestore.patchMemory(_auth.coupleId!, id, {'likedBy': likedBy});
    } else {
      memories[index] = updated;
      await _db.updateMemory(updated);
    }
    await markDiscoverViewed(id);
  }

  Future<void> starDiscoverMemory(int id) async {
    final uid = _auth.uid;
    if (uid == null) return;
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final memory = memories[index];

    final starredBy = memory.starredBy.contains(uid)
        ? memory.starredBy
        : [...memory.starredBy, uid];
    final updated = memory.copyWith(
      starredBy: starredBy,
      isFavorite: true,
    );

    if (_useCloud && await _isOnline()) {
      await _firestore.patchMemory(_auth.coupleId!, id, {
        'starredBy': starredBy,
        'isFavorite': true,
      });
    } else {
      memories[index] = updated;
      await _db.updateMemory(updated);
    }
    await markDiscoverViewed(id);
  }

  Future<void> addNoteToMemory(int id, String text, {bool alsoMarkDiscoverViewed = false}) async {
    final uid = _auth.uid;
    if (uid == null || text.trim().isEmpty) return;
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final memory = memories[index];

    final note = MemoryComment(
      uid: uid,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    final comments = [...memory.comments, note];
    final updated = memory.copyWith(comments: comments);

    await _patchMemory(index, updated, {
      'comments': comments.map((c) => c.toFirestore()).toList(),
    });
    if (alsoMarkDiscoverViewed) await markDiscoverViewed(id);
  }

  Future<void> addDiscoverComment(int id, String text) =>
      addNoteToMemory(id, text, alsoMarkDiscoverViewed: true);

  Future<void> markNotesSeen(int id) async {
    final uid = _auth.uid;
    if (uid == null) return;
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final memory = memories[index];
    final notesSeenAtBy = Map<String, String>.from(memory.notesSeenAtBy);
    notesSeenAtBy[uid] = DateTime.now().toIso8601String();
    final updated = memory.copyWith(notesSeenAtBy: notesSeenAtBy);
    await _patchMemory(index, updated, {'notesSeenAtBy': notesSeenAtBy});
  }

  Future<void> setReminder(int id, DateTime? when) async {
    final index = memories.indexWhere((m) => m.id == id);
    if (index == -1) return;
    final updated = memories[index].copyWith(reminderAt: when);
    await _patchMemory(
      index,
      updated,
      when != null
          ? {'reminderAt': when.toIso8601String()}
          : {'reminderAt': null},
    );
    Get.snackbar(
      'Reminder',
      when == null ? 'Reminder cleared' : 'We\'ll remind you on ${when.toLocal()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _patchMemory(
    int index,
    Memory updated,
    Map<String, dynamic> patch,
  ) async {
    if (_useCloud && await _isOnline()) {
      await _firestore.patchMemory(_auth.coupleId!, updated.id, patch);
    } else {
      memories[index] = updated;
      await _db.updateMemory(updated);
    }
  }

  List<Memory> get favoriteMemories =>
      memories.where((m) => m.isFavorite).toList();

  int get daysTogether {
    if (memories.isEmpty) return 0;
    final firstDate = memories.last.date;
    return DateTime.now().difference(firstDate).inDays;
  }

  Future<void> _loadDefaultMemories() async {
    final defaultMemories = [
      Memory(
        id: DateTime(2024, 1, 14).millisecondsSinceEpoch,
        date: DateTime(2024, 1, 14),
        title: 'Our First Date',
        description:
            'The day everything changed. Coffee turned into hours of conversation, and I knew you were special.',
        location: 'Café Moments',
        isFavorite: true,
        isTogetherMoment: true,
        mediaFiles: [],
      ),
      Memory(
        id: DateTime(2024, 2, 14).millisecondsSinceEpoch,
        date: DateTime(2024, 2, 14),
        title: 'Valentine\'s Day Magic',
        description:
            'You looked stunning in that red dress. The way you smiled when I gave you those roses... unforgettable.',
        location: 'Riverside Restaurant',
        isFavorite: false,
        isTogetherMoment: true,
        mediaFiles: [],
      ),
      Memory(
        id: DateTime(2024, 3, 20).millisecondsSinceEpoch,
        date: DateTime(2024, 3, 20),
        title: 'Sunset at the Beach',
        description:
            'Walking hand in hand, the waves at our feet. You laughed so freely, and my heart was completely yours.',
        location: 'Paradise Beach',
        isFavorite: true,
        isTogetherMoment: true,
        mediaFiles: [],
      ),
      Memory(
        id: DateTime(2024, 5, 10).millisecondsSinceEpoch,
        date: DateTime(2024, 5, 10),
        title: 'Movie Night Cuddles',
        description:
            'We didn\'t even finish the movie. Just being close to you was all the entertainment I needed.',
        location: 'Home Sweet Home',
        isFavorite: false,
        isTogetherMoment: true,
        mediaFiles: [],
      ),
    ];

    for (var memory in defaultMemories) {
      if (_useCloud && await _isOnline()) {
        await _firestore.createMemory(_auth.coupleId!, memory);
      } else {
        final json = memory.toJson();
        json['createdAt'] = memory.date.millisecondsSinceEpoch;
        await _db.createMemory(Memory.fromJson(json));
      }
    }
    if (!_useCloud) {
      await loadMemories();
    } else {
      // Stream may already be empty; push defaults into UI immediately.
      memories.value = [...memories, ...defaultMemories]
        ..sort((a, b) => b.date.compareTo(a.date));
      memories.refresh();
    }
  }

  @override
  void onClose() {
    _firestoreSub?.cancel();
    _db.close();
    super.onClose();
  }
}
