import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? textColor;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final bool isYellowGradient;

  const CustomButton({
    super.key,
    required this.buttonName,
    this.onPressed,
    this.isLoading = false,
    this.textColor,
    this.gradientColors,
    this.backgroundColor,
    this.isYellowGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Green Gradient (Sign In, Save Changes, etc.)
    final List<Color> greenGradient = [
      const Color(0xFF004D40), // Dark deep green
      const Color(0xFF00D193), // Bright emerald
    ];

    // 2. Yellow-Green Gradient (Download, View All History, Select Plans)
    final List<Color> yellowToGreenGradient = [
      const Color(0xFFE2C255), // Golden yellow
      const Color(0xFF5CB06E), // Muted green
    ];

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
                    colors: gradientColors ?? (isYellowGradient ? yellowToGreenGradient : greenGradient),
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: backgroundColor == null ? [
              BoxShadow(
                color: (isYellowGradient ? yellowToGreenGradient[1] : greenGradient[1]).withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
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
                      fontSize: 15.sp,
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
