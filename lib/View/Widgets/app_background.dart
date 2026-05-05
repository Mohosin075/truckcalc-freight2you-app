import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

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
          // Left Side Glow
          Positioned(
            left: -150,
            top: 100,
            child: Container(
              width: 400,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Right Side Glow
          Positioned(
            right: -150,
            bottom: 50,
            child: Container(
              width: 400,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00D193).withOpacity(0.2),
                    const Color(0xFF00D193).withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle grid pattern or texture could be added here if needed
          child,
        ],
      ),
    );
  }
}
