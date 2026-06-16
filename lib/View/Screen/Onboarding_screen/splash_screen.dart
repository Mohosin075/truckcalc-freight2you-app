import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/bottom_nav_bar.dart';
import 'package:truckcalc/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String name = 'splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for splash animation/time
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    
    // AuthController initialize is called in main.dart, but we ensure it's done
    if (!authController.isLoggedIn) {
      await authController.initialize();
    }

    if (mounted) {
      if (authController.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(BottomNavBarScreen.name);
      } else {
        Navigator.of(context).pushReplacementNamed(LogInScreen.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imagePath: 'assets/images/authimg.png',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo-cal.png',
                width: 120.w,
                height: 80.h,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              SizedBox(height: 10.h),
              Text(
                'truckcalc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
