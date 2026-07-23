import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/services/couple_settings_service.dart';
import 'app_settings.dart';

class SettingsController extends GetxController {
  final Rx<AppSettings> settings = AppSettings().obs;
  final RxBool isLoading = true.obs;

  final CoupleSettingsService _coupleSettings = CoupleSettingsService.instance;
  StreamSubscription<AppSettings?>? _coupleSub;
  String? _listeningCoupleId;
  bool _applyingRemote = false;
  bool _didSeedCoupleSettings = false;

  AuthController? get _auth {
    try {
      return Get.find<AuthController>();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // loadSettings() is awaited from main() before runApp — don't reload here
    // or Obx/theme listeners fire mid-startup and can blank the first frame.
    final auth = _auth;
    if (auth != null) {
      ever(auth.profile, (_) => _bindCoupleSettings());
      _bindCoupleSettings();
    }
  }

  @override
  void onClose() {
    _coupleSub?.cancel();
    super.onClose();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      settings.value = await AppSettings.load();
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _bindCoupleSettings() {
    final coupleId = _auth?.coupleId;
    if (coupleId == null || coupleId.isEmpty || !(_auth?.hasCouple ?? false)) {
      _coupleSub?.cancel();
      _coupleSub = null;
      _listeningCoupleId = null;
      _didSeedCoupleSettings = false;
      return;
    }
    if (_listeningCoupleId == coupleId && _coupleSub != null) return;

    _coupleSub?.cancel();
    _listeningCoupleId = coupleId;
    _didSeedCoupleSettings = false;
    _coupleSub = _coupleSettings.watchAppSettings(coupleId).listen(
      (remote) {
        if (remote == null) {
          if (!_didSeedCoupleSettings) {
            _didSeedCoupleSettings = true;
            _pushToCouple();
          }
          return;
        }
        if (settings.value.hasSameSyncValues(remote)) return;
        _applyRemote(remote);
      },
      onError: (e) => print('Couple settings stream error: $e'),
    );
  }

  Future<void> _applyRemote(AppSettings remote) async {
    _applyingRemote = true;
    try {
      settings.value = remote;
      settings.refresh();
      await remote.save();
      _refreshTheme();
    } finally {
      _applyingRemote = false;
    }
  }

  Future<void> _persistAndSync() async {
    settings.refresh();
    await settings.value.save();
    _refreshTheme();
    if (!_applyingRemote) {
      await _pushToCouple();
    }
  }

  Future<void> _pushToCouple() async {
    final auth = _auth;
    final coupleId = auth?.coupleId;
    final uid = auth?.uid;
    if (auth == null ||
        coupleId == null ||
        uid == null ||
        !auth.hasCouple) {
      return;
    }
    try {
      await _coupleSettings.saveAppSettings(
        coupleId: coupleId,
        settings: settings.value,
        updatedBy: uid,
      );
    } catch (e) {
      print('Failed to sync couple settings: $e');
    }
  }

  void _refreshTheme() {
    // Prefer theme APIs over forceAppUpdate — full app rebuild can leave the
    // native launch screen visible if the first Flutter frame is dropped.
    Get.changeTheme(AppTheme.themeData);
    Get.changeThemeMode(
      AppTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> updateColorPalette(ColorPalette palette) async {
    settings.value.selectedPalette = palette;
    // Selecting a palette adopts its preferred light/dark mode.
    settings.value.isDarkMode = palette.defaultDark;
    await _persistAndSync();
  }

  Future<void> setDarkMode(bool enabled) async {
    if (settings.value.isDarkMode == enabled) return;
    settings.value.isDarkMode = enabled;
    await _persistAndSync();
  }

  Future<void> toggleDarkMode() => setDarkMode(!settings.value.isDarkMode);

  Future<void> updateFontCombination(FontCombination fontCombination) async {
    settings.value.selectedFontCombination = fontCombination;
    await _persistAndSync();
  }

  // Keep for backward compatibility
  @Deprecated('Use updateFontCombination instead')
  Future<void> updateFont(FontOption font) async {
    final combination = AppSettings.fontCombinations.firstWhere(
      (fc) => fc.headingFont.id == font.id || fc.bodyFont.id == font.id,
      orElse: () => AppSettings.fontCombinations.first,
    );
    await updateFontCombination(combination);
  }

  Future<void> updateTextCustomization({
    String? appTitle,
    String? appSubtitle,
    String? newMemoryButton,
    String? timelineTab,
    String? galleryTab,
    String? favoritesTab,
  }) async {
    if (appTitle != null) settings.value.appTitle = appTitle;
    if (appSubtitle != null) settings.value.appSubtitle = appSubtitle;
    if (newMemoryButton != null) {
      settings.value.newMemoryButton = newMemoryButton;
    }
    if (timelineTab != null) settings.value.timelineTab = timelineTab;
    if (galleryTab != null) settings.value.galleryTab = galleryTab;
    if (favoritesTab != null) settings.value.favoritesTab = favoritesTab;

    await _persistAndSync();
  }
}
