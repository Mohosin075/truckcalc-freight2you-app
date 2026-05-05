import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/bottom_nav_bar.dart';
import 'package:gathering_app/View/Screen/authentication_screen/forgot_pass_screen.dart';
import 'package:gathering_app/View/Screen/authentication_screen/sign_up_screen.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:gathering_app/View/Widgets/auth_textFormField.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  static const String name = '/log-in';

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Icon(Icons.local_shipping, size: 60.w, color: Colors.white),
              SizedBox(height: 10.h),
              Text(
                'truckcalc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 60.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      AuthTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: '••••••••',
                        isPassword: true,
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF004D40), Color(0xFF00D193)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, BottomNavBarScreen.name);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, ForgotPassScreen.name);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, SignUpScreen.name);
                },
                child: const Text(
                  'New here? Create account',
                  style: TextStyle(color: Color(0xFF4C86FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
