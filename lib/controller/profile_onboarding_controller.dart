import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/data/profile_options.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/services/user_profile_service.dart';

class ProfileOnboardingController extends GetxController {
  final UserProfileService _profileService = UserProfileService.instance;

  final Rx<ProfileOnboardingStep> step = ProfileOnboardingStep.details.obs;
  final RxBool isSaving = false.obs;
  final Rx<UserProfile> draft = UserProfile(uid: '').obs;
  bool isEditMode = false;
  ProfileOnboardingStep? _editOnlyStep;

  final RxSet<String> customHobbies = <String>{}.obs;
  final RxSet<String> customLanguages = <String>{}.obs;
  final RxSet<String> customDreamTravel = <String>{}.obs;
  final RxSet<String> customSkills = <String>{}.obs;
  final RxSet<String> customWantsToLearn = <String>{}.obs;

  String? get uid => Get.find<AuthController>().uid;

  List<String> get hobbyOptions =>
      {...ProfileOptions.hobbies, ...customHobbies}.toList()..sort();
  List<String> get languageOptions =>
      {...ProfileOptions.languages, ...customLanguages}.toList()..sort();
  List<String> get dreamTravelOptions =>
      {...ProfileOptions.dreamTravel, ...customDreamTravel}.toList()..sort();
  List<String> get skillOptions =>
      {...ProfileOptions.skills, ...customSkills}.toList()..sort();
  List<String> get learnOptions =>
      {...ProfileOptions.wantsToLearn, ...customWantsToLearn}.toList()..sort();

  @override
  void onInit() {
    super.onInit();
    _parseRouteArgs();
    _loadExisting();
  }

  void _parseRouteArgs() {
    final args = Get.arguments;
    if (args is Map && args['mode'] == 'edit') {
      isEditMode = true;
      final stepName = args['step'] as String?;
      if (stepName != null) {
        for (final candidate in ProfileOnboardingStep.values) {
          if (candidate.name == stepName) {
            _editOnlyStep = candidate;
            break;
          }
        }
      }
    }
  }

  Future<void> _loadExisting() async {
    final id = uid;
    if (id == null) return;
    final profile = await _profileService.getUserProfile(id);
    draft.value = UserProfile(
      uid: id,
      profileCompleted: profile.profileCompleted,
      profileSkipped: profile.profileSkipped,
      firstName: profile.firstName,
      lastName: profile.lastName,
      nickname: profile.nickname,
      nicknameSetBy: profile.nicknameSetBy,
      photoPath: profile.photoPath,
      birthday: profile.birthday,
      gender: profile.gender,
      hobbies: profile.hobbies,
      languages: profile.languages,
      dreamTravel: profile.dreamTravel,
      skills: profile.skills,
      wantsToLearn: profile.wantsToLearn,
      onboardingStep: profile.onboardingStep,
    );
    _hydrateCustomLists(profile);
    if (isEditMode) {
      step.value = _editOnlyStep ?? ProfileOnboardingStep.details;
    } else {
      step.value = _resolveResumeStep(profile);
    }
  }

  ProfileOnboardingStep _resolveResumeStep(UserProfile profile) {
    final saved = UserProfile.parseOnboardingStep(profile.onboardingStep);
    if (saved != null) return saved;
    return _resolveStartingStep(profile);
  }

  ProfileOnboardingStep _resolveStartingStep(UserProfile profile) {
    if ((profile.firstName?.trim().isEmpty ?? true) ||
        (profile.lastName?.trim().isEmpty ?? true)) {
      return ProfileOnboardingStep.details;
    }
    if (profile.gender?.trim().isEmpty ?? true) {
      return ProfileOnboardingStep.gender;
    }
    if (profile.hobbies.isEmpty) return ProfileOnboardingStep.hobbies;
    if (profile.languages.isEmpty) return ProfileOnboardingStep.languages;
    if (profile.dreamTravel.isEmpty) return ProfileOnboardingStep.dreamTravel;
    if (profile.skills.isEmpty) return ProfileOnboardingStep.skills;
    return ProfileOnboardingStep.wantsToLearn;
  }

  void _hydrateCustomLists(UserProfile profile) {
    customHobbies.addAll(
      profile.hobbies.where((e) => !ProfileOptions.hobbies.contains(e)),
    );
    customLanguages.addAll(
      profile.languages.where((e) => !ProfileOptions.languages.contains(e)),
    );
    customDreamTravel.addAll(
      profile.dreamTravel.where((e) => !ProfileOptions.dreamTravel.contains(e)),
    );
    customSkills.addAll(
      profile.skills.where((e) => !ProfileOptions.skills.contains(e)),
    );
    customWantsToLearn.addAll(
      profile.wantsToLearn
          .where((e) => !ProfileOptions.wantsToLearn.contains(e)),
    );
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    draft.value = draft.value.copyWith(photoPath: file.path);
  }

  void updateDraft(UserProfile Function(UserProfile current) transform) {
    draft.value = transform(draft.value);
  }

  void toggleInList({
    required List<String> field,
    required String item,
    required void Function(List<String>) setter,
  }) {
    final list = List<String>.from(field);
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
    setter(list);
  }

  void toggleHobby(String item) => updateDraft((p) {
        final list = List<String>.from(p.hobbies);
        list.contains(item) ? list.remove(item) : list.add(item);
        return p.copyWith(hobbies: list);
      });

  void toggleLanguage(String item) => updateDraft((p) {
        final list = List<String>.from(p.languages);
        list.contains(item) ? list.remove(item) : list.add(item);
        return p.copyWith(languages: list);
      });

  void toggleDreamTravel(String item) => updateDraft((p) {
        final list = List<String>.from(p.dreamTravel);
        list.contains(item) ? list.remove(item) : list.add(item);
        return p.copyWith(dreamTravel: list);
      });

  void toggleSkill(String item) => updateDraft((p) {
        final list = List<String>.from(p.skills);
        list.contains(item) ? list.remove(item) : list.add(item);
        return p.copyWith(skills: list);
      });

  void toggleWantsToLearn(String item) => updateDraft((p) {
        final list = List<String>.from(p.wantsToLearn);
        list.contains(item) ? list.remove(item) : list.add(item);
        return p.copyWith(wantsToLearn: list);
      });

  void addCustomItem(ProfileOnboardingStep target, String value) {
    switch (target) {
      case ProfileOnboardingStep.hobbies:
        customHobbies.add(value);
        toggleHobby(value);
      case ProfileOnboardingStep.languages:
        customLanguages.add(value);
        toggleLanguage(value);
      case ProfileOnboardingStep.dreamTravel:
        customDreamTravel.add(value);
        toggleDreamTravel(value);
      case ProfileOnboardingStep.skills:
        customSkills.add(value);
        toggleSkill(value);
      case ProfileOnboardingStep.wantsToLearn:
        customWantsToLearn.add(value);
        toggleWantsToLearn(value);
      default:
        break;
    }
  }

  Future<void> _persistDraft({
    bool completed = false,
    ProfileOnboardingStep? checkpoint,
  }) async {
    final id = uid;
    if (id == null) return;
    isSaving.value = true;
    try {
      final toSave = UserProfile(
        uid: id,
        profileCompleted: completed,
        profileSkipped: false,
        firstName: draft.value.firstName,
        lastName: draft.value.lastName,
        nickname: draft.value.nickname,
        nicknameSetBy: draft.value.nicknameSetBy,
        photoPath: draft.value.photoPath,
        birthday: draft.value.birthday,
        gender: draft.value.gender,
        hobbies: draft.value.hobbies,
        languages: draft.value.languages,
        dreamTravel: draft.value.dreamTravel,
        skills: draft.value.skills,
        wantsToLearn: draft.value.wantsToLearn,
        onboardingStep: completed
            ? null
            : (checkpoint ?? step.value).name,
      );
      if (completed) {
        await _profileService.markCompleted(toSave);
      } else {
        await _profileService.saveProfile(toSave);
      }
      draft.value = toSave;
      await Get.find<AuthController>().refreshUserProfile();
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> skipForNow() async {
    await _persistDraft(completed: false, checkpoint: step.value);
    _goNextAfterOnboarding();
  }

  Future<void> continueStep() async {
    final current = step.value;

    if (current == ProfileOnboardingStep.details) {
      if (draft.value.firstName?.trim().isEmpty ?? true) {
        Get.snackbar('Required', 'Please enter your first name');
        return;
      }
      if (draft.value.lastName?.trim().isEmpty ?? true) {
        Get.snackbar('Required', 'Please enter your last name');
        return;
      }
    }

    if (current == ProfileOnboardingStep.gender &&
        (draft.value.gender?.isEmpty ?? true)) {
      Get.snackbar('Required', 'Please select an option');
      return;
    }

    final isLast = !isEditMode && current == ProfileOnboardingStep.wantsToLearn;
    final next = current.next;
    final shouldComplete = isEditMode
        ? draft.value.isDataComplete
        : isLast;

    await _persistDraft(
      completed: shouldComplete,
      checkpoint: shouldComplete ? null : (isLast ? null : (next ?? current)),
    );

    if (isEditMode || isLast) {
      if (isEditMode) {
        Get.back();
      } else {
        _goNextAfterOnboarding();
      }
      return;
    }

    if (next != null) step.value = next;
  }

  void goBack() {
    if (isEditMode) {
      Get.back();
    }
    // Incomplete onboarding: no back navigation.
  }

  void _goNextAfterOnboarding() {
    final auth = Get.find<AuthController>();
    if (!auth.hasCouple) {
      Get.offAllNamed(AppRoutes.coupleSetup);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> pickBirthday() async {
    final initial = draft.value.birthday ?? DateTime(1995, 7, 11);
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.secondaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      draft.value = draft.value.copyWith(birthday: picked);
    }
  }
}
