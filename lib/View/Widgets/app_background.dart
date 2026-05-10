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
      decoration: const BoxDecoration(
        color: Color(0xFF010B0B),
      ),
      child: Stack(
        children: [
          // Background Image with Pattern - Increased visibility
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                imagePath ?? 'assets/images/authimg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Left Top Glow - More vibrant
          Positioned(
            left: -80.w,
            top: -50.h,
            child: Container(
              width: 350.w,
              height: 350.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Right Middle Glow
          Positioned(
            right: -100.w,
            top: 250.h,
            child: Container(
              width: 450.w,
              height: 450.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Left Bottom Glow
          Positioned(
            left: -120.w,
            bottom: -50.h,
            child: Container(
              width: 450.w,
              height: 450.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}
