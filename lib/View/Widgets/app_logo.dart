import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo-cal.png',
      width: width?.w ?? 100.w,
      height: height?.h ?? 60.h,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
