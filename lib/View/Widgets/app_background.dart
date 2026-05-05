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
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.5),
          radius: 1.5,
          colors: [
            Color(0xFF004D40),
            Color(0xFF010B0B),
          ],
          stops: [0.0, 0.8],
        ),
      ),
      child: Stack(
        children: [
          // Add another glow at the bottom right
          Positioned(
            right: -100,
            bottom: -100,
            child: Container(
              width: 300,
              height: 300,
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
          child,
        ],
      ),
    );
  }
}
