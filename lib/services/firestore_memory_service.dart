import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';

class FirestoreMemoryService {
  static final FirestoreMemoryService instance = FirestoreMemoryService._();
  FirestoreMemoryService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _memoriesRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('memories');

  Stream<List<Memory>> watchMemories(String coupleId) {
    return _memoriesRef(coupleId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Memory.fromFirestore(d.data(), d.id))
            .toList());
  }

  Future<List<Memory>> getMemories(String coupleId) async {
    final snap = await _memoriesRef(coupleId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Memory.fromFirestore(d.data(), d.id)).toList();
  }

  Future<List<Memory>> getDeletedMemories(String coupleId) async {
    final snap = await _memoriesRef(coupleId)
        .where('isDeleted', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Memory.fromFirestore(d.data(), d.id)).toList();
  }

  Future<Memory> createMemory(String coupleId, Memory memory, {String? createdBy}) async {
    final id = memory.id.toString();
    final data = memory.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    if (createdBy != null) data['createdBy'] = createdBy;
    await _memoriesRef(coupleId).doc(id).set(data);
    return memory.copyWith(createdBy: createdBy);
  }

  Future<void> patchMemory(String coupleId, int id, Map<String, dynamic> patch) async {
    await _memoriesRef(coupleId).doc(id.toString()).update(patch);
  }

  Future<void> updateMemory(String coupleId, Memory memory) async {
    await _memoriesRef(coupleId)
        .doc(memory.id.toString())
        .update(memory.toFirestore());
  }

  Future<void> softDelete(String coupleId, int id) async {
    await _memoriesRef(coupleId).doc(id.toString()).update({'isDeleted': true});
  }

  Future<void> restore(String coupleId, int id) async {
    await _memoriesRef(coupleId).doc(id.toString()).update({'isDeleted': false});
  }

  Future<void> permanentDelete(String coupleId, int id) async {
    await _memoriesRef(coupleId).doc(id.toString()).delete();
  }

  Future<void> clearAll(String coupleId) async {
    final snap = await _memoriesRef(coupleId).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
