import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/bottom_nav_bar.dart';
import 'package:truckcalc/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:truckcalc/View/Widgets/app_logo.dart';

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
      body: Stack(
        children: [
          // store-thump.svg — full-screen app thumbnail/background
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/store-thump.svg',
              fit: BoxFit.cover,
            ),
          ),

          // Only logo SVG centered
          const Center(
            child: AppLogo(
              width: 140,
              height: 90,
            ),
          ),
        ],
      ),
    );
  }
}
