import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/profile_onboarding_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/data/profile_options.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';
import 'package:yaaram/view/widgets/profile/profile_chip_grid.dart';
import 'package:yaaram/view/widgets/profile/profile_screen_widgets.dart';

class ProfileOnboardingScreen extends StatelessWidget {
  const ProfileOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileOnboardingController>();

    return Obx(() {
      final step = c.step.value;
      final saving = c.isSaving.value;
      final profile = c.draft.value;
      final isEdit = c.isEditMode;

      return PopScope(
        canPop: isEdit,
        child: ProfileScreenShell(
        title: step.title,
        subtitle: step.subtitle,
        onSkip: isEdit ? null : c.skipForNow,
        showBack: isEdit,
        onBack: isEdit ? () => Get.back() : null,
        bottomBar: ProfileContinueButton(
          onPressed: c.continueStep,
          loading: saving,
          label: isEdit
              ? 'Save'
              : step == ProfileOnboardingStep.wantsToLearn
                  ? 'Confirm'
                  : 'Continue',
        ),
        child: switch (step) {
          ProfileOnboardingStep.details => _DetailsStep(
              profile: profile,
              onPickPhoto: c.pickPhoto,
              onPickBirthday: c.pickBirthday,
              onFirstName: (v) => c.updateDraft((p) => p.copyWith(firstName: v)),
              onLastName: (v) => c.updateDraft((p) => p.copyWith(lastName: v)),
            ),
          ProfileOnboardingStep.gender => ProfileGenderOptions(
              options: ProfileOptions.genderPresets,
              selected: profile.gender,
              onSelect: (g) => c.updateDraft((p) => p.copyWith(gender: g)),
              onChooseAnother: () async {
                final value = await showProfileAddItemDialog(
                  context: context,
                  title: 'Your gender',
                  hint: 'Type your gender',
                );
                if (value != null) {
                  c.updateDraft((p) => p.copyWith(gender: value));
                }
              },
            ),
          ProfileOnboardingStep.hobbies => _SelectionStep(
              options: c.hobbyOptions,
              selected: profile.hobbies.toSet(),
              onToggle: c.toggleHobby,
              onAddNew: () => _addNew(context, c, step),
            ),
          ProfileOnboardingStep.languages => _SelectionStep(
              options: c.languageOptions,
              selected: profile.languages.toSet(),
              onToggle: c.toggleLanguage,
              onAddNew: () => _addNew(context, c, step),
            ),
          ProfileOnboardingStep.dreamTravel => _SelectionStep(
              options: c.dreamTravelOptions,
              selected: profile.dreamTravel.toSet(),
              onToggle: c.toggleDreamTravel,
              onAddNew: () => _addNew(context, c, step),
            ),
          ProfileOnboardingStep.skills => _SelectionStep(
              options: c.skillOptions,
              selected: profile.skills.toSet(),
              onToggle: c.toggleSkill,
              onAddNew: () => _addNew(context, c, step),
            ),
          ProfileOnboardingStep.wantsToLearn => _SelectionStep(
              options: c.learnOptions,
              selected: profile.wantsToLearn.toSet(),
              onToggle: c.toggleWantsToLearn,
              onAddNew: () => _addNew(context, c, step),
            ),
        },
        ),
      );
    });
  }

  Future<void> _addNew(
    BuildContext context,
    ProfileOnboardingController c,
    ProfileOnboardingStep step,
  ) async {
    final value = await showProfileAddItemDialog(
      context: context,
      title: 'Add new',
      hint: 'Enter a value',
    );
    if (value != null) c.addCustomItem(step, value);
  }
}

class _SelectionStep extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onAddNew;

  const _SelectionStep({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAddNewButton(onTap: onAddNew),
        ProfileChipGrid(
          options: options,
          selected: selected,
          onToggle: onToggle,
        ),
      ],
    );
  }
}

class _DetailsStep extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickBirthday;
  final ValueChanged<String> onFirstName;
  final ValueChanged<String> onLastName;

  const _DetailsStep({
    required this.profile,
    required this.onPickPhoto,
    required this.onPickBirthday,
    required this.onFirstName,
    required this.onLastName,
  });

  @override
  State<_DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<_DetailsStep> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.profile.firstName ?? '');
    _lastName = TextEditingController(text: widget.profile.lastName ?? '');
  }

  @override
  void didUpdateWidget(covariant _DetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.nickname != oldWidget.profile.nickname) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final birthday = widget.profile.birthday;
    final birthdayLabel = birthday != null
        ? DateFormat('MMMM d, yyyy').format(birthday)
        : 'Choose birthday date';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  child: widget.profile.photoPath != null &&
                          File(widget.profile.photoPath!).existsSync()
                      ? Image.file(
                          File(widget.profile.photoPath!),
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 14.w,
                          color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                        ),
                ),
              ),
              GestureDetector(
                onTap: widget.onPickPhoto,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 4.5.w),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          AppTextField(
            controller: _firstName,
            label: 'First name',
            onChanged: widget.onFirstName,
          ),
          SizedBox(height: 2.5.h),
          AppTextField(
            controller: _lastName,
            label: 'Last name',
            onChanged: widget.onLastName,
          ),
          SizedBox(height: 2.5.h),
          _ReadOnlyNicknameField(nickname: widget.profile.nickname),
          SizedBox(height: 2.5.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPickBirthday,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Ink(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: AppTheme.secondaryColor),
                    SizedBox(width: 3.w),
                    Text(
                      birthdayLabel,
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeMedium.sp,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }
}

class _ReadOnlyNicknameField extends StatelessWidget {
  final String? nickname;

  const _ReadOnlyNicknameField({this.nickname});

  @override
  Widget build(BuildContext context) {
    final hasNickname = nickname?.trim().isNotEmpty == true;

    return InputDecorator(
      decoration: AppTextField.decoration('Nickname').copyWith(
        hintText: 'Waiting for your partner…',
        helperText: 'Only your partner can give you a nickname',
        helperStyle: AppTheme.getCaptionStyle(
          fontSize: AppTheme.fontSizeSmall.sp,
          color: AppTheme.secondaryColor.withValues(alpha: 0.85),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.secondaryColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
      ),
      child: Text(
        hasNickname ? nickname!.trim() : 'Waiting for your partner…',
        style: AppTheme.getBodyStyle(
          fontSize: AppTheme.fontSizeLarge.sp,
          color: hasNickname
              ? AppTheme.textPrimary
              : AppTheme.textSecondary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
