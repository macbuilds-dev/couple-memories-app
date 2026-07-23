import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';

class IconMenuItem<T> {
  final T value;
  final IconData icon;

  const IconMenuItem({
    required this.value,
    required this.icon,
  });
}

/// Square trigger + matching-width icon-only popup (Moments / Chat).
class ThemedIconMenuButton<T> extends StatelessWidget {
  final T? value;
  final List<IconMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final double? size;
  final IconData? triggerIcon;

  const ThemedIconMenuButton({
    super.key,
    this.value,
    required this.items,
    required this.onSelected,
    this.size,
    this.triggerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final side = size ?? 11.w;
    final muted = AppTheme.textSecondary.withValues(alpha: 0.4);
    IconData leadingIcon = triggerIcon ?? Icons.more_horiz;
    if (triggerIcon == null && value != null) {
      for (final item in items) {
        if (item.value == value) {
          leadingIcon = item.icon;
          break;
        }
      }
    }

    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: PopupMenuButton<T>(
        initialValue: value,
        onSelected: onSelected,
        offset: Offset(0, side + 1.h),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        color: AppTheme.surfaceColor,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: side),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          side: BorderSide(
            color: AppTheme.secondaryColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        itemBuilder: (context) => items.map((item) {
          final selected = value != null && item.value == value;
          return PopupMenuItem<T>(
            value: item.value,
            height: side,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: side,
              height: side,
              child: Center(
                child: Icon(
                  item.icon,
                  size: side * 0.48,
                  color: selected ? AppTheme.secondaryColor : muted,
                ),
              ),
            ),
          );
        }).toList(),
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: AppTheme.secondaryColor.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Icon(
            leadingIcon,
            color: AppTheme.secondaryColor,
            size: side * 0.48,
          ),
        ),
      ),
    );
  }
}
