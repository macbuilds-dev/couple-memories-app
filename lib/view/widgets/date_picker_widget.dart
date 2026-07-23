import 'package:flutter/material.dart' hide DateUtils;
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../../controller/utils/date_utils.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(1990),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.secondaryColor,
                    onPrimary: Colors.white,
                    surface: AppTheme.surfaceColor,
                    onSurface: AppTheme.textPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) onDateSelected(picked);
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: AppTheme.secondaryColor.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: AppTheme.secondaryColor,
                  size: 4.5.w,
                ),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: AppTheme.getCaptionStyle(
                        fontSize: AppTheme.fontSizeSmall.sp,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      '${selectedDate.day} ${DateUtils.getMonthName(selectedDate.month, full: true)} ${selectedDate.year}',
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeLarge.sp,
                        color: AppTheme.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
