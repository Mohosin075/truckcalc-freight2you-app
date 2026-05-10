import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? textColor;
  final List<Color>? gradientColors;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.buttonName,
    this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.gradientColors,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 50.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: backgroundColor == null
                ? LinearGradient(
                    colors: gradientColors ?? [const Color(0xFF004D40), const Color(0xFF00D193)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: CircularProgressIndicator(
                      color: textColor ?? Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    buttonName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
