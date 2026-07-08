import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/view/widgets/app_logo_widget.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _indicatorWidth = 36.0;
  static const _indicatorHeight = 3.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.secondaryColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 8.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 4;
              final indicatorLeft =
                  tabWidth * currentIndex + (tabWidth - _indicatorWidth) / 2;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: indicatorLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: _indicatorWidth,
                      height: _indicatorHeight,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _NavTab(
                        selected: currentIndex == 0,
                        onTap: () => onTap(0),
                        icon: _CardsNavIcon(
                          active: currentIndex == 0,
                          inactiveColor: AppTheme.textSecondary.withValues(alpha: 0.45),
                        ),
                      ),
                      _NavTab(
                        selected: currentIndex == 1,
                        onTap: () => onTap(1),
                        icon: _HeartNavIcon(
                          active: currentIndex == 1,
                          inactiveColor: AppTheme.textSecondary.withValues(alpha: 0.45),
                        ),
                      ),
                      _NavTab(
                        selected: currentIndex == 2,
                        onTap: () => onTap(2),
                        icon: _ChatNavIcon(
                          active: currentIndex == 2,
                          inactiveColor: AppTheme.textSecondary.withValues(alpha: 0.45),
                        ),
                      ),
                      _NavTab(
                        selected: currentIndex == 3,
                        onTap: () => onTap(3),
                        icon: _ProfileNavIcon(active: currentIndex == 3),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget icon;

  const _NavTab({
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(child: icon),
        ),
      ),
    );
  }
}

class _CardsNavIcon extends StatelessWidget {
  final bool active;
  final Color inactiveColor;

  const _CardsNavIcon({
    required this.active,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = active ? AppTheme.secondaryColor : inactiveColor;

    return SizedBox(
      width: 9.5.w,
      height: 7.5.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 0.6.w,
            child: Transform.rotate(
              angle: 0.2,
              child: _navCard(
                fill: Colors.transparent,
                border: accent,
                w: 5.6.w,
                h: 6.6.w,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.14,
              child: _navCard(
                fill: active
                    ? AppTheme.secondaryColor.withValues(alpha: 0.18)
                    : Colors.transparent,
                border: accent,
                w: 5.6.w,
                h: 6.6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCard({
    required Color fill,
    required Color border,
    required double w,
    required double h,
  }) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: border, width: 1.6),
      ),
    );
  }
}

class _HeartNavIcon extends StatelessWidget {
  final bool active;
  final Color inactiveColor;

  const _HeartNavIcon({
    required this.active,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.secondaryColor : inactiveColor;

    return Icon(
      active ? Icons.favorite : Icons.favorite_border,
      color: color,
      size: 7.w,
    );
  }
}

class _ChatNavIcon extends StatelessWidget {
  final bool active;
  final Color inactiveColor;

  const _ChatNavIcon({
    required this.active,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.secondaryColor : inactiveColor;

    return Icon(
      active ? Icons.chat_bubble : Icons.chat_bubble_outline,
      color: color,
      size: 7.w,
    );
  }
}

class _ProfileNavIcon extends StatelessWidget {
  final bool active;

  const _ProfileNavIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: active ? 1 : 0.55,
      child: Container(
        decoration: active
            ? BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryColor, width: 2),
              )
            : null,
        child: AppLogoWidget(
          size: 7.5,
          showShadow: false,
        ),
      ),
    );
  }
}
