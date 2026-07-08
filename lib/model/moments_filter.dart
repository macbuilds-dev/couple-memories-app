enum MomentsFilter {
  all,
  together,
  mine,
  partner,
}

extension MomentsFilterX on MomentsFilter {
  String get label {
    switch (this) {
      case MomentsFilter.all:
        return 'All';
      case MomentsFilter.together:
        return 'Together';
      case MomentsFilter.mine:
        return 'Mine';
      case MomentsFilter.partner:
        return 'Partner';
    }
  }
}
