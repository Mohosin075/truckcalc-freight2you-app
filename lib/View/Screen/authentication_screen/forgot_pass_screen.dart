import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:gathering_app/View/Widgets/auth_textFormField.dart';

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Reset password',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              SizedBox(height: 40.h),
              if (!_isSent) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Forgot password',
                    style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10.h),
                const Text(
                  'Enter your email address and we will send you a link',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 40.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'Email address',
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
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
                            setState(() => _isSent = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text('Send reset link'),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(height: 100.h),
                const Icon(Icons.mail_outline, size: 80, color: Colors.white),
                SizedBox(height: 20.h),
                Text(
                  'Check your email',
                  style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Text(
                  'We sent a reset link to ${_emailController.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 40.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to login',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
