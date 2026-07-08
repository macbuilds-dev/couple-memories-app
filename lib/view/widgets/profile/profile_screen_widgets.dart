import 'package:flutter/material.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:yaaram/controller/utils/theme/app_theme.dart';

import 'package:yaaram/view/widgets/app_screen_shell.dart';



class ProfileScreenShell extends StatelessWidget {

  final String title;

  final String? subtitle;

  final Widget child;

  final VoidCallback? onSkip;

  final VoidCallback? onBack;

  final Widget? bottomBar;

  final bool showBack;



  const ProfileScreenShell({

    super.key,

    required this.title,

    this.subtitle,

    required this.child,

    this.onSkip,

    this.onBack,

    this.bottomBar,

    this.showBack = false,

  });



  @override

  Widget build(BuildContext context) {

    return AppScreenShell(

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        automaticallyImplyLeading: false,

        leading: showBack && onBack != null

            ? _SquareIconButton(

                icon: Icons.chevron_left,

                onTap: onBack!,

              )

            : const SizedBox.shrink(),

        actions: [

          if (onSkip != null)

            TextButton(

              onPressed: onSkip,

              child: Text(

                'Skip',

                style: AppTheme.getBodyStyle(

                  fontSize: AppTheme.fontSizeLarge.sp,

                  color: AppTheme.secondaryColor,

                ).copyWith(fontWeight: FontWeight.w600),

              ),

            ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Expanded(

            child: SingleChildScrollView(

              padding: EdgeInsets.only(bottom: 2.h),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Padding(

                    padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 1.5.h),

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          title,

                          style: AppTheme.getHeadingStyle(

                            fontSize: AppTheme.fontSizeXXL.sp,

                            color: AppTheme.textSecondary,

                          ).copyWith(height: 1.25),

                        ),

                        if (subtitle != null) ...[

                          SizedBox(height: 1.h),

                          Text(

                            subtitle!,

                            style: AppTheme.getBodyStyle(

                              fontSize: AppTheme.fontSizeMedium.sp,

                              color: AppTheme.textPrimary.withValues(alpha: 0.75),

                            ),

                          ),

                        ],

                      ],

                    ),

                  ),

                  child,

                ],

              ),

            ),

          ),

          if (bottomBar != null) bottomBar!,

        ],

      ),

    );

  }

}



class _SquareIconButton extends StatelessWidget {

  final IconData icon;

  final VoidCallback onTap;



  const _SquareIconButton({required this.icon, required this.onTap});



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: EdgeInsets.only(left: 4.w),

      child: Align(

        alignment: Alignment.centerLeft,

        child: InkWell(

          onTap: onTap,

          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),

          child: Container(

            width: 10.w,

            height: 10.w,

            decoration: BoxDecoration(

              color: AppTheme.surfaceColor,

              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),

              border: Border.all(

                color: AppTheme.secondaryColor.withValues(alpha: 0.2),

              ),

            ),

            child: Icon(icon, color: AppTheme.secondaryColor, size: 6.w),

          ),

        ),

      ),

    );

  }

}



class ProfileContinueButton extends StatelessWidget {

  final String label;

  final VoidCallback? onPressed;

  final bool loading;



  const ProfileContinueButton({

    super.key,

    this.label = 'Continue',

    required this.onPressed,

    this.loading = false,

  });



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 3.h),

      child: SizedBox(

        width: double.infinity,

        child: ElevatedButton(

          onPressed: loading ? null : onPressed,

          style: ElevatedButton.styleFrom(

            backgroundColor: AppTheme.secondaryColor,

            foregroundColor: Colors.white,

            padding: EdgeInsets.symmetric(vertical: 2.2.h),

            shape: RoundedRectangleBorder(

              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),

            ),

            elevation: 0,

          ),

          child: loading

              ? const SizedBox(

                  height: 22,

                  width: 22,

                  child: CircularProgressIndicator(

                    color: Colors.white,

                    strokeWidth: 2,

                  ),

                )

              : Text(

                  label,

                  style: AppTheme.getBodyStyle(

                    fontSize: AppTheme.fontSizeLarge.sp,

                    color: Colors.white,

                  ).copyWith(fontWeight: FontWeight.w600),

                ),

        ),

      ),

    );

  }

}



class ProfileAddNewButton extends StatelessWidget {

  final VoidCallback onTap;



  const ProfileAddNewButton({super.key, required this.onTap});



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: EdgeInsets.symmetric(horizontal: 6.w),

      child: Align(

        alignment: Alignment.centerRight,

        child: TextButton.icon(

          onPressed: onTap,

          icon: Icon(Icons.add, color: AppTheme.secondaryColor, size: 5.w),

          label: Text(

            'Add new',

            style: AppTheme.getBodyStyle(

              fontSize: AppTheme.fontSizeMedium.sp,

              color: AppTheme.secondaryColor,

            ).copyWith(fontWeight: FontWeight.w600),

          ),

        ),

      ),

    );

  }

}



Future<String?> showProfileAddItemDialog({

  required BuildContext context,

  required String title,

  required String hint,

}) {

  return showDialog<String>(

    context: context,

    barrierDismissible: true,

    builder: (dialogContext) => _ProfileAddItemDialog(

      title: title,

      hint: hint,

    ),

  );

}



class _ProfileAddItemDialog extends StatefulWidget {

  final String title;

  final String hint;



  const _ProfileAddItemDialog({

    required this.title,

    required this.hint,

  });



  @override

  State<_ProfileAddItemDialog> createState() => _ProfileAddItemDialogState();

}



class _ProfileAddItemDialogState extends State<_ProfileAddItemDialog> {

  late final TextEditingController _controller;



  @override

  void initState() {

    super.initState();

    _controller = TextEditingController();

  }



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  void _close([String? result]) {

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(result);

  }



  @override

  Widget build(BuildContext context) {

    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;



    return Dialog(

      backgroundColor: AppTheme.surfaceColor,

      insetPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),

      ),

      child: ConstrainedBox(

        constraints: BoxConstraints(maxHeight: maxHeight),

        child: SingleChildScrollView(

          padding: EdgeInsets.all(5.w),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                widget.title,

                style: AppTheme.getHeadingStyle(

                  fontSize: AppTheme.fontSizeXL.sp,

                  color: AppTheme.textSecondary,

                ),

              ),

              SizedBox(height: 2.h),

              AppTextField(controller: _controller, label: widget.hint),

              SizedBox(height: 3.h),

              Row(

                children: [

                  Expanded(

                    child: OutlinedButton(

                      onPressed: _close,

                      style: OutlinedButton.styleFrom(

                        side: BorderSide(

                          color: AppTheme.secondaryColor.withValues(alpha: 0.4),

                        ),

                        foregroundColor: AppTheme.textPrimary,

                      ),

                      child: const Text('Cancel'),

                    ),

                  ),

                  SizedBox(width: 3.w),

                  Expanded(

                    child: ElevatedButton(

                      onPressed: () {

                        final value = _controller.text.trim();

                        if (value.isEmpty) return;

                        _close(value);

                      },

                      style: ElevatedButton.styleFrom(

                        backgroundColor: AppTheme.secondaryColor,

                        foregroundColor: Colors.white,

                      ),

                      child: const Text('Add'),

                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

      ),

    );

  }

}


