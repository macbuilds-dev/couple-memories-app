import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/admin_session_controller.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/database_admin.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/utils/media_utils.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/profile/my_profile_screen.dart';
import 'package:yaaram/view/profile/profile_menu_tile.dart';
import 'package:yaaram/view/widgets/admin/admin_settings_list_widget.dart';
import 'package:yaaram/view/widgets/admin/admin_unlock_dialog.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  Map<String, dynamic>? _dbInfo;
  String _appVersion = '';
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  static const _versionTapTarget = 7;
  static const _versionTapResetMs = 2500;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
    _loadAppVersion();
  }

  Future<void> _loadDatabaseInfo() async {
    final info = await DatabaseAdmin.getDatabaseInfo();
    if (mounted) setState(() => _dbInfo = info);
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    }
  }

  String _headerName(AuthController auth) {
    final profile = auth.userProfile.value;
    if (profile?.nickname?.trim().isNotEmpty == true) {
      return profile!.nickname!.trim();
    }
    if (profile?.firstName?.trim().isNotEmpty == true) {
      return profile!.firstName!.trim();
    }
    return auth.firebaseUser.value?.displayName?.split(' ').first ??
        auth.firebaseUser.value?.email?.split('@').first ??
        'You';
  }

  Future<void> _onVersionTap() async {
    final now = DateTime.now();
    if (_lastVersionTap != null &&
        now.difference(_lastVersionTap!).inMilliseconds > _versionTapResetMs) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;

    if (_versionTapCount < _versionTapTarget) return;

    _versionTapCount = 0;
    _lastVersionTap = null;

    final adminSession = Get.find<AdminSessionController>();
    if (adminSession.isUnlocked.value) return;

    await showAdminUnlockDialog();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final adminSession = Get.find<AdminSessionController>();

    return Obx(() {
      final profile = auth.userProfile.value;
      final headerName = _headerName(auth);
      final photoPath = profile?.photoPath;
      final showAdminTools = adminSession.isUnlocked.value;

      return Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
          child: Column(
            children: [
              _ProfileHeaderCard(
                name: headerName,
                photoPath: photoPath,
              ),
              SizedBox(height: 3.h),
              ProfileMenuTile(
                icon: Icons.person_outline,
                title: 'My Profile',
                onTap: () => Get.to(() => const MyProfileScreen()),
              ),
              ProfileMenuTile(
                icon: Icons.palette_outlined,
                title: 'Color Palette',
                onTap: AppSettingsNavigation.openColorPalette,
              ),
              ProfileMenuTile(
                icon: Icons.font_download_outlined,
                title: 'Font Combination',
                onTap: AppSettingsNavigation.openFontCombination,
              ),
              ProfileMenuTile(
                icon: Icons.text_fields_outlined,
                title: 'Customized Text',
                onTap: AppSettingsNavigation.openCustomizedText,
              ),
              if (showAdminTools) ...[
                SizedBox(height: 1.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Developer tools',
                      style: AppTheme.getCaptionStyle(
                        fontSize: AppTheme.fontSizeSmall.sp,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                ProfileMenuTile(
                  icon: Icons.storage_outlined,
                  title: 'Database',
                  onTap: NavigationHelper.toDatabaseAdmin,
                ),
                ProfileMenuTile(
                  icon: Icons.favorite_border,
                  title: 'Manage Memories',
                  onTap: NavigationHelper.toMemoriesAdmin,
                ),
                ProfileMenuTile(
                  icon: Icons.info_outline,
                  title: 'Database Info',
                  onTap: () => AppSettingsNavigation.showDatabaseInfo(_dbInfo),
                ),
              ],
              ProfileMenuTile(
                icon: Icons.logout,
                title: 'Log out',
                iconColor: Colors.red.shade400,
                titleColor: Colors.red.shade400,
                onTap: AppSettingsNavigation.confirmLogout,
              ),
              SizedBox(height: 3.h),
              _AppVersionFooter(
                version: _appVersion,
                onTap: _onVersionTap,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String? photoPath;

  const _ProfileHeaderCard({
    required this.name,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 12.w,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
            backgroundImage:
                hasPhoto ? MediaUtils.imageProvider(photoPath!) : null,
            child: !hasPhoto
                ? Icon(
                    Icons.person_outline,
                    size: 12.w,
                    color: AppTheme.secondaryColor,
                  )
                : null,
          ),
          SizedBox(height: 2.h),
          Text(
            name,
            style: AppTheme.getHeadingStyle(
              fontSize: AppTheme.fontSizeXXL.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppVersionFooter extends StatelessWidget {
  final String version;
  final VoidCallback onTap;

  const _AppVersionFooter({
    required this.version,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = version.isEmpty ? 'Our Love Story' : 'Version $version';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.getCaptionStyle(
            fontSize: AppTheme.fontSizeSmall.sp,
            color: AppTheme.textSecondary.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
