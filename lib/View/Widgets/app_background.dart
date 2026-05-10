import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? imagePath;

  const AppBackground({super.key, required this.child, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF010B0B), // Deep dark base from the image
      child: Stack(
        children: [
          // 1. Prominent Diagonal Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.8, // Increased opacity to match the bright stripes in the user image
              child: Image.asset(
                imagePath ?? 'assets/images/authimg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Large Bottom-Left Glow
          Positioned(
            left: -180.w,
            bottom: -150.h,
            child: Container(
              width: 500.w,
              height: 500.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withValues(alpha: 0.45),
                    const Color(0xFF00D193).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Middle-Right Vertical Glow
          Positioned(
            right: -200.w,
            top: 200.h,
            child: Container(
              width: 500.w,
              height: 800.h, // Stretched vertically as seen in screenshots
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withValues(alpha: 0.45),
                    const Color(0xFF00D193).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 4. Content Area
          child,
        ],
      ),
    );
  }
}
