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
    // Scale up the logo size by 1.5x to make it look larger and clearer
    final double computedWidth = (width ?? 130) * 1.5;
    final double computedHeight = (height ?? 80) * 1.5;

    return Image.asset(
      'assets/images/logo.png',
      width: computedWidth.w,
      height: computedHeight.h,
      fit: fit,
    );
  }
}


