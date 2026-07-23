import 'package:flutter/material.dart';

enum MomentsFilter {
  all,
  together,
  mine,
  partner,
  saved,
  noted,
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
      case MomentsFilter.saved:
        return 'Saved';
      case MomentsFilter.noted:
        return 'Notes';
    }
  }

  IconData get icon {
    switch (this) {
      case MomentsFilter.all:
        return Icons.apps;
      case MomentsFilter.together:
        return Icons.favorite;
      case MomentsFilter.mine:
        return Icons.person;
      case MomentsFilter.partner:
        return Icons.group;
      case MomentsFilter.saved:
        return Icons.star;
      case MomentsFilter.noted:
        return Icons.chat_bubble;
    }
  }
}
