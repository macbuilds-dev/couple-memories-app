import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/data/profile_options.dart';

class ProfileChipGrid extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const ProfileChipGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 2.8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final item = options[index];
        final isSelected = selected.contains(item);
        return _ProfileChip(
          label: item,
          icon: ProfileOptions.iconFor(item),
          selected: isSelected,
          onTap: () => onToggle(item),
        );
      },
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.secondaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: selected
                  ? accent
                  : AppTheme.secondaryColor.withValues(alpha: 0.35),
              width: selected ? 2 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 4.5.w,
                  color: selected ? Colors.white : accent,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getCaptionStyle(
                      fontSize: AppTheme.fontSizeSmall.sp,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileGenderOptions extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onChooseAnother;

  const ProfileGenderOptions({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onChooseAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      child: Column(
        children: [
          ...options.map((option) {
            final isSelected = selected == option;
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: _GenderTile(
                label: option,
                selected: isSelected,
                onTap: () => onSelect(option),
              ),
            );
          }),
          _GenderTile(
            label: 'Choose another',
            selected: selected != null && !options.contains(selected),
            trailing: Icons.chevron_right,
            onTap: onChooseAnother,
          ),
        ],
      ),
    );
  }
}

class _GenderTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailing;

  const _GenderTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.secondaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Ink(
          height: 7.h,
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: selected
                  ? accent
                  : AppTheme.secondaryColor.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.getBodyStyle(
                      fontSize: AppTheme.fontSizeLarge.sp,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(
                  trailing ?? Icons.check,
                  color: selected
                      ? Colors.white
                      : AppTheme.textSecondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
