import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/services/user_profile_service.dart';
import 'package:yaaram/utils/media_utils.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _profileService = UserProfileService.instance;

  Future<void> _pickPhoto(UserProfile profile) async {
    final uid = Get.find<AuthController>().uid;
    if (uid == null) return;

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final updated = profile.copyWith(photoPath: file.path);
    await _profileService.saveProfile(updated);
    await Get.find<AuthController>().refreshUserProfile();
  }

  String get _fullName {
    final p = Get.find<AuthController>().userProfile.value;
    if (p == null) return 'You';
    return '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim().isEmpty
        ? 'You'
        : '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final profile = auth.userProfile.value;
      if (profile == null) {
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          appBar: _appBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      final dob = profile.birthday != null
          ? DateFormat('MMMM d, yyyy').format(profile.birthday!)
          : 'Not set';

      return Scaffold(
        appBar: _appBar(),
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PhotoHeader(
                profile: profile,
                onPickPhoto: () => _pickPhoto(profile),
              ),
              SizedBox(height: 3.h),
              _InfoRow(
                label: 'Full name',
                value: _fullName,
              ),
              _divider(),
              _InfoRow(
                label: 'Nickname',
                value: profile.nickname?.trim().isNotEmpty == true
                    ? profile.nickname!.trim()
                    : 'Waiting for your partner…',
                valueMuted: profile.nickname?.trim().isEmpty ?? true,
                subtitle: 'Only your partner can give you a nickname',
              ),
              _divider(),
              _InfoRow(label: 'Date of birth', value: dob),
              _divider(),
              _InfoRow(
                label: 'Gender',
                value: profile.gender?.trim().isNotEmpty == true
                    ? profile.gender!.trim()
                    : 'Not set',
                valueMuted: profile.gender?.trim().isEmpty ?? true,
              ),
              SizedBox(height: 2.h),
              _ChipSection(
                title: 'Ask me about my hobbies and interests',
                items: profile.hobbies,
              ),
              _ChipSection(
                title: 'I would like to know more about',
                items: profile.wantsToLearn,
              ),
              _ChipSection(
                title: 'My languages',
                items: profile.languages,
              ),
              _ChipSection(
                title: 'I know about',
                items: profile.skills,
              ),
              _ChipSection(
                title: 'I am planning to travel to',
                items: profile.dreamTravel,
              ),
            ],
          ),
        ),
      ),
      );
    });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'My Profile',
        style: AppTheme.getHeadingStyle(
          fontSize: AppTheme.fontSizeXL.sp,
          color: AppTheme.textSecondary,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () => _showEditPicker(context),
          child: Text(
            'Edit',
            style: AppTheme.getBodyStyle(
              fontSize: AppTheme.fontSizeMedium.sp,
              color: AppTheme.secondaryColor,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: AppTheme.textSecondary.withValues(alpha: 0.12),
      );

  void _showEditPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusMedium),
        ),
      ),
      builder: (ctx) {
        final sections = [
          (ProfileOnboardingStep.details, 'Personal details'),
          (ProfileOnboardingStep.gender, 'Gender'),
          (ProfileOnboardingStep.hobbies, 'Hobbies & interests'),
          (ProfileOnboardingStep.languages, 'Languages'),
          (ProfileOnboardingStep.dreamTravel, 'Dream travel'),
          (ProfileOnboardingStep.skills, 'Skills & knowledge'),
          (ProfileOnboardingStep.wantsToLearn, 'Want to learn more'),
        ];

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit profile',
                  style: AppTheme.getHeadingStyle(
                    fontSize: AppTheme.fontSizeXL.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 1.5.h),
                ...sections.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      entry.$2,
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeMedium.sp,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Get.toNamed(
                        AppRoutes.profileOnboarding,
                        arguments: {
                          'mode': 'edit',
                          'step': entry.$1.name,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onPickPhoto;

  const _PhotoHeader({
    required this.profile,
    required this.onPickPhoto,
  });

  String get _headerLabel {
    if (profile.nickname?.trim().isNotEmpty == true) {
      return profile.nickname!.trim();
    }
    if (profile.firstName?.trim().isNotEmpty == true) {
      return profile.firstName!.trim();
    }
    return 'You';
  }

  @override
  Widget build(BuildContext context) {
    final path = profile.photoPath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 14.w,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              backgroundImage: path != null && File(path).existsSync()
                  ? MediaUtils.imageProvider(path)
                  : null,
              child: path == null || !File(path).existsSync()
                  ? Icon(
                      Icons.person_outline,
                      size: 14.w,
                      color: AppTheme.secondaryColor,
                    )
                  : null,
            ),
            GestureDetector(
              onTap: onPickPhoto,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surfaceColor, width: 2),
                ),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 4.w),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          _headerLabel,
          textAlign: TextAlign.center,
          style: AppTheme.getHeadingStyle(
            fontSize: AppTheme.fontSizeXXL.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool valueMuted;

  const _InfoRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.valueMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.getCaptionStyle(
              fontSize: AppTheme.fontSizeSmall.sp,
              color: AppTheme.textSecondary.withValues(alpha: 0.65),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.getBodyStyle(
              fontSize: AppTheme.fontSizeLarge.sp,
              color: valueMuted
                  ? AppTheme.textSecondary.withValues(alpha: 0.45)
                  : AppTheme.textPrimary,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 0.4.h),
            Text(
              subtitle!,
              style: AppTheme.getCaptionStyle(
                fontSize: AppTheme.fontSizeSmall.sp,
                color: AppTheme.secondaryColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ChipSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final chipColor = AppTheme.secondaryColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.getBodyStyle(
              fontSize: AppTheme.fontSizeMedium.sp,
              color: AppTheme.textSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 1.2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: items.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: chipColor.withValues(alpha: 0.55)),
                ),
                child: Text(
                  item,
                  style: AppTheme.getCaptionStyle(
                    fontSize: AppTheme.fontSizeSmall.sp,
                    color: chipColor,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
