import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/otp_verify_controller.dart';
import 'package:truckcalc/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/app_logo.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class VerifyAccount extends StatefulWidget {
  static const String name = '/verify-account';

  final String email; // Sign Up থেকে পাস করা ইমেইল

  const VerifyAccount({super.key, required this.email});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  final TextEditingController otpController = TextEditingController();
  bool _inProgress = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  // Resend OTP ফাংশন (পরে API যোগ করবে)
  Future<void> _resendOtp() async {
    setState(() {
      _inProgress = true;
    });

    // এখানে Resend OTP API কল করবে
    // await someController.resendOtp(widget.email);

    await Future.delayed(const Duration(seconds: 2)); // ডেমো

    setState(() {
      _inProgress = false;
    });

    if (mounted) {
      showCustomSnackBar(
        context: context,
        message: "New OTP sent to ${widget.email}",
        isError: false,
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
              SizedBox(height: 60.h),
              const AppLogo(
                width: 100,
                height: 60,
              ),
              SizedBox(height: 10.h),
              Text(
                'truckcalc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
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
                    Text(
                      'Code Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                        ),
                        text: 'Enter the 6-digit code sent to\n',
                        children: [
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
                      textStyle: const TextStyle(
                        fontSize: 20,
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
                    CustomButton(
                      onPressed: _submitOtp,
                      buttonName: 'Submit',
                      isLoading: _inProgress,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    text: "Didn't receive the code? ",
                    children: [
                      TextSpan(
                        text: 'Resend Again',
                        style: const TextStyle(
                          color: Color(0xFF00D193),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _inProgress ? null : _resendOtp,
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

  Future<void> _submitOtp() async {
    if (_inProgress || otpController.text.trim().length != 6) {
      showCustomSnackBar(
        context: context,
        message: "Please enter a valid 6-digit OTP",
      );
      return;
    }

    setState(() {
      _inProgress = true;
    });

    try {
      final otpVerifyCtrl = Provider.of<OtpVerifyController>(
        context,
        listen: false,
      );

      final bool success = await otpVerifyCtrl.verifyOtp(
        email: widget.email,
        otp: otpController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        showCustomSnackBar(
          context: context,
          message: "Account verified successfully! please log in..",
          isError: false,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          LogInScreen.name,
          (predicate) => false,
        );
      } else {
        showCustomSnackBar(
          context: context,
          message: otpVerifyCtrl.errorMessage ?? "Invalid OTP. Try again.",
        );
      }
    } catch (e) {
      debugPrint("❌ OTP verification error: $e");
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message: "An unexpected error occurred. Please try again.",
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _inProgress = false;
        });
      }
    }
  }
}
