import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/forgot_pass_controller.dart';
import 'package:truckcalc/View/Screen/authentication_screen/new_password_screen.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../Widgets/CustomButton.dart';
import '../../Widgets/app_logo.dart';

class CodeSubmit extends StatefulWidget {
  const CodeSubmit({super.key});
  static const String name = '/code-submit';

  @override
  State<CodeSubmit> createState() => _CodeSubmitState();
}

class _CodeSubmitState extends State<CodeSubmit> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final forgotPassController = Provider.of<ForgotPasswordController>(
      context,
      listen: false,
    );
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
                      'Code Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Enter the 6-Digit code sent to you at\n${forgotPassController.savedEmail}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    PinCodeTextField(
                      backgroundColor: Colors.transparent,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.none,
                      keyboardType: TextInputType.number,
                      cursorColor: const Color(0xFF00D193),
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12.r),
                        fieldHeight: 45.h,
                        fieldWidth: 45.w,
                        activeColor: Colors.white.withOpacity(0.2),
                        inactiveColor: Colors.white.withOpacity(0.1),
                        selectedColor: const Color(0xFF00D193),
                        activeFillColor: Colors.white.withOpacity(0.05),
                        selectedFillColor: Colors.white.withOpacity(0.1),
                        inactiveFillColor: Colors.white.withOpacity(0.02),
                        borderWidth: 1,
                      ),
                      enableActiveFill: true,
                      appContext: context,
                      controller: otpController,
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 30.h),
                    Consumer<ForgotPasswordController>(
                      builder: (context, forgotController, child) {
                        return CustomButton(
                          buttonName: 'Submit',
                          isLoading: forgotController.inProgress,
                          onPressed: onTapSubmit,
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    text: "Don't receive code? ",
                    children: [
                      TextSpan(
                        text: 'Resend Again',
                        style: const TextStyle(
                          color: Color(0xFF00D193),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = ontapResendCode,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> ontapResendCode() async {
    final forgotPassController = Provider.of<ForgotPasswordController>(
      context,
      listen: false,
    );
    bool isSuccess = await forgotPassController.forgotPassword(
      forgotPassController.savedEmail,
    );
    if (isSuccess && mounted) {
      showCustomSnackBar(
        context: context,
        message: 'Code resent to ${forgotPassController.savedEmail}',
        isError: false,
      );
    } else if (mounted) {
      showCustomSnackBar(
        context: context,
        message: forgotPassController.errorMessage ?? 'Resend failed',
      );
    }
  }

  void onTapSubmit() async {
    final forgotPassController = Provider.of<ForgotPasswordController>(
      context,
      listen: false,
    );

    bool isSuccess = await forgotPassController.verifyOTP(
      otpController.text.trim(),
    );

    if (isSuccess) {
      showCustomSnackBar(
        context: context,
        message: 'Verification successful! Now create your new password.',
        isError: false,
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        NewPasswordScreen.name,
        (predicate) => false,
      );
    } else {
      showCustomSnackBar(
        context: context,
        message: forgotPassController.errorMessage ?? 'Something went wrong!',
      );
    }
  }

  // Removed redundant function
}
