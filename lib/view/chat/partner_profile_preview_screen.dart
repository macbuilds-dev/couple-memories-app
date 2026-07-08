import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/services/user_profile_service.dart';
import 'package:yaaram/utils/media_utils.dart';

/// Read-only partner profile view. Firestore RBAC allows partners to read
/// each other's profile fields; only nickname is writable by partner.
class PartnerProfilePreviewScreen extends StatefulWidget {
  final String partnerUid;
  final UserProfile? initialProfile;

  const PartnerProfilePreviewScreen({
    super.key,
    required this.partnerUid,
    this.initialProfile,
  });

  @override
  State<PartnerProfilePreviewScreen> createState() =>
      _PartnerProfilePreviewScreenState();
}

class _PartnerProfilePreviewScreenState
    extends State<PartnerProfilePreviewScreen> {
  final _profileService = UserProfileService.instance;
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _profileService.getPartnerProfile(widget.partnerUid);
      if (mounted) setState(() => _profile = profile);
    } catch (e) {
      if (mounted) {
        Get.snackbar('Could not load profile', e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fullName(UserProfile p) {
    final name = '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim();
    return name.isEmpty ? 'Partner' : name;
  }

  String _nicknameLabel(UserProfile p) {
    if (p.nickname?.trim().isNotEmpty == true) {
      return p.nickname!.trim();
    }
    return 'Not set yet';
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Partner profile',
          style: AppTheme.getHeadingStyle(
            fontSize: AppTheme.fontSizeXL.sp,
            color: AppTheme.textSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: _loading && profile == null
            ? const Center(child: CircularProgressIndicator())
            : profile == null
                ? Center(
                    child: Text(
                      'Profile unavailable',
                      style: AppTheme.getBodyStyle(
                        color: AppTheme.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PhotoHeader(profile: profile),
                        SizedBox(height: 3.h),
                        _InfoRow(label: 'Full name', value: _fullName(profile)),
                        _divider(),
                        _InfoRow(
                          label: 'Nickname',
                          value: _nicknameLabel(profile),
                          valueMuted: profile.nickname?.trim().isEmpty ?? true,
                          subtitle: 'You can set this from chat options',
                        ),
                        _divider(),
                        _InfoRow(
                          label: 'Date of birth',
                          value: profile.birthday != null
                              ? DateFormat('MMMM d, yyyy')
                                  .format(profile.birthday!)
                              : 'Not shared',
                          valueMuted: profile.birthday == null,
                        ),
                        _divider(),
                        _InfoRow(
                          label: 'Gender',
                          value: profile.gender?.trim().isNotEmpty == true
                              ? profile.gender!.trim()
                              : 'Not shared',
                          valueMuted: profile.gender?.trim().isEmpty ?? true,
                        ),
                        SizedBox(height: 2.h),
                        _ChipSection(
                          title: 'Hobbies & interests',
                          items: profile.hobbies,
                        ),
                        _ChipSection(
                          title: 'Languages',
                          items: profile.languages,
                        ),
                        _ChipSection(
                          title: 'Dream travel',
                          items: profile.dreamTravel,
                        ),
                        _ChipSection(
                          title: 'Skills & knowledge',
                          items: profile.skills,
                        ),
                        _ChipSection(
                          title: 'Wants to learn',
                          items: profile.wantsToLearn,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: AppTheme.textSecondary.withValues(alpha: 0.12),
      );
}

class _PhotoHeader extends StatelessWidget {
  final UserProfile profile;

  const _PhotoHeader({required this.profile});

  String get _headerLabel {
    if (profile.nickname?.trim().isNotEmpty == true) {
      return profile.nickname!.trim();
    }
    if (profile.firstName?.trim().isNotEmpty == true) {
      return profile.firstName!.trim();
    }
    return 'Partner';
  }

  @override
  Widget build(BuildContext context) {
    final path = profile.photoPath;

    return Column(
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
        SizedBox(height: 2.h),
        Text(
          _headerLabel,
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
                color: AppTheme.textSecondary.withValues(alpha: 0.55),
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

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
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
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: items
                .map(
                  (item) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.5.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      item,
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeSmall.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
