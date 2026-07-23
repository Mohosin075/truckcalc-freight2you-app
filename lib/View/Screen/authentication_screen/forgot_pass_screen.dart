import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/app_logo.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Widgets/auth_textFormField.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});
  static const String name = '/forgot-pass-screen';

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imagePath: 'assets/images/authimg.png',
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 100.h),
              const AppLogo(
                width: 240,
                height: 140,
              ),
              SizedBox(height: 60.h),
              if (!_isSent) ...[
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Forgot password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      const Text(
                        'Enter your email address and we will send you a link',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 30.h),
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'Email address',
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        buttonName: 'Send reset link',
                        onPressed: () {
                          setState(() => _isSent = true);
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Check your email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'We sent a reset link to ${_emailController.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 30.h),
                      CustomButton(
                        buttonName: 'Back to login',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              if (!_isSent)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Back to login',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
