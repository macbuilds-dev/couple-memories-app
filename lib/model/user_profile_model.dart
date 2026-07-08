class UserProfile {
  final String uid;
  final bool profileCompleted;
  final bool profileSkipped;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? nicknameSetBy;
  final String? photoPath;
  final DateTime? birthday;
  final String? gender;
  final List<String> hobbies;
  final List<String> languages;
  final List<String> dreamTravel;
  final List<String> skills;
  final List<String> wantsToLearn;
  final String? onboardingStep;

  const UserProfile({
    required this.uid,
    this.profileCompleted = false,
    this.profileSkipped = false,
    this.firstName,
    this.lastName,
    this.nickname,
    this.nicknameSetBy,
    this.photoPath,
    this.birthday,
    this.gender,
    this.hobbies = const [],
    this.languages = const [],
    this.dreamTravel = const [],
    this.skills = const [],
    this.wantsToLearn = const [],
    this.onboardingStep,
  });

  bool get needsOnboarding => !profileCompleted;

  /// All onboarding sections filled (used to auto-complete after edits or skip+fill).
  bool get isDataComplete {
    if (firstName?.trim().isEmpty ?? true) return false;
    if (lastName?.trim().isEmpty ?? true) return false;
    if (gender?.trim().isEmpty ?? true) return false;
    if (hobbies.isEmpty) return false;
    if (languages.isEmpty) return false;
    if (dreamTravel.isEmpty) return false;
    if (skills.isEmpty) return false;
    if (wantsToLearn.isEmpty) return false;
    return true;
  }

  String get displayFirstName =>
      firstName?.trim().isNotEmpty == true ? firstName!.trim() : 'You';

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      profileCompleted: data['profileCompleted'] as bool? ?? false,
      profileSkipped: data['profileSkipped'] as bool? ?? false,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      nickname: data['nickname'] as String?,
      nicknameSetBy: data['nicknameSetBy'] as String?,
      photoPath: data['photoPath'] as String?,
      birthday: _parseDate(data['birthday']),
      gender: data['gender'] as String?,
      hobbies: _stringList(data['hobbies']),
      languages: _stringList(data['languages']),
      dreamTravel: _stringList(data['dreamTravel']),
      skills: _stringList(data['skills']),
      wantsToLearn: _stringList(data['wantsToLearn']),
      onboardingStep: data['onboardingStep'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'profileCompleted': profileCompleted,
        'profileSkipped': profileSkipped,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (nickname != null) 'nickname': nickname,
        if (nicknameSetBy != null) 'nicknameSetBy': nicknameSetBy,
        if (photoPath != null) 'photoPath': photoPath,
        if (birthday != null) 'birthday': birthday!.toIso8601String(),
        if (gender != null) 'gender': gender,
        'hobbies': hobbies,
        'languages': languages,
        'dreamTravel': dreamTravel,
        'skills': skills,
        'wantsToLearn': wantsToLearn,
        if (onboardingStep != null) 'onboardingStep': onboardingStep,
      };

  UserProfile copyWith({
    bool? profileCompleted,
    bool? profileSkipped,
    String? firstName,
    String? lastName,
    String? nickname,
    String? nicknameSetBy,
    String? photoPath,
    DateTime? birthday,
    String? gender,
    List<String>? hobbies,
    List<String>? languages,
    List<String>? dreamTravel,
    List<String>? skills,
    List<String>? wantsToLearn,
    String? onboardingStep,
    bool clearOnboardingStep = false,
  }) {
    return UserProfile(
      uid: uid,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      profileSkipped: profileSkipped ?? this.profileSkipped,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      nicknameSetBy: nicknameSetBy ?? this.nicknameSetBy,
      photoPath: photoPath ?? this.photoPath,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      hobbies: hobbies ?? this.hobbies,
      languages: languages ?? this.languages,
      dreamTravel: dreamTravel ?? this.dreamTravel,
      skills: skills ?? this.skills,
      wantsToLearn: wantsToLearn ?? this.wantsToLearn,
      onboardingStep:
          clearOnboardingStep ? null : (onboardingStep ?? this.onboardingStep),
    );
  }

  static ProfileOnboardingStep? parseOnboardingStep(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final step in ProfileOnboardingStep.values) {
      if (step.name == value) return step;
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

enum ProfileOnboardingStep {
  details,
  gender,
  hobbies,
  languages,
  dreamTravel,
  skills,
  wantsToLearn,
}

extension ProfileOnboardingStepX on ProfileOnboardingStep {
  String get title {
    switch (this) {
      case ProfileOnboardingStep.details:
        return 'Profile details';
      case ProfileOnboardingStep.gender:
        return 'I am a';
      case ProfileOnboardingStep.hobbies:
        return 'What are your hobbies and interests?';
      case ProfileOnboardingStep.languages:
        return 'What languages can you communicate in?';
      case ProfileOnboardingStep.dreamTravel:
        return 'Which is your dream travel city/country?';
      case ProfileOnboardingStep.skills:
        return 'What skills and knowledge do you have?';
      case ProfileOnboardingStep.wantsToLearn:
        return 'What would you like to know more about?';
    }
  }

  String? get subtitle {
    switch (this) {
      case ProfileOnboardingStep.hobbies:
      case ProfileOnboardingStep.languages:
      case ProfileOnboardingStep.dreamTravel:
      case ProfileOnboardingStep.skills:
      case ProfileOnboardingStep.wantsToLearn:
        return 'Select a few options that describe you best.';
      default:
        return null;
    }
  }

  ProfileOnboardingStep? get next {
    final index = ProfileOnboardingStep.values.indexOf(this);
    if (index >= ProfileOnboardingStep.values.length - 1) return null;
    return ProfileOnboardingStep.values[index + 1];
  }

  ProfileOnboardingStep? get previous {
    final index = ProfileOnboardingStep.values.indexOf(this);
    if (index <= 0) return null;
    return ProfileOnboardingStep.values[index - 1];
  }
}
