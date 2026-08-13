import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/Controller/forgot_pass_controller.dart';
import 'package:truckcalc/View/Screen/authentication_screen/code_submit.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/app_logo.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Widgets/auth_textFormField.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});
  static const String name = '/forgot-pass-screen';

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;

  Future<void> _handleSendResetLink(ForgotPasswordController controller) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showCustomSnackBar(
        context: context,
        message: 'Please enter your email address',
        isError: true,
      );
      return;
    }

    final success = await controller.forgotPassword(email);
    if (success && mounted) {
      showCustomSnackBar(
        context: context,
        message: 'OTP sent successfully to $email',
        isError: false,
      );
      Navigator.pushNamed(context, CodeSubmit.name);
    } else if (mounted) {
      showCustomSnackBar(
        context: context,
        message: controller.errorMessage ?? 'Failed to send OTP',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imagePath: 'assets/images/authimg.png',
        child: SingleChildScrollView(
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
                      Consumer<ForgotPasswordController>(
                        builder: (context, forgotController, child) {
                          return CustomButton(
                            buttonName: 'Send reset link',
                            isLoading: forgotController.inProgress,
                            onPressed: () => _handleSendResetLink(forgotController),
                          );
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
