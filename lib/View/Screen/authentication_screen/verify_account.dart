import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/otp_verify_controller.dart';
import 'package:gathering_app/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:gathering_app/View/Widgets/CustomButton.dart';
import 'package:gathering_app/View/Widgets/appbar.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: common_appbar(titleName: 'Verify Account'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Submit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 12.h),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                text: 'Enter the 6-digit code sent to\n',
                children: [
                  TextSpan(
                    text: widget.email,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
    
            // OTP Pin Field
          PinCodeTextField(
              backgroundColor: Colors.transparent,
              length: 6,
              obscureText: false,
              animationType: AnimationType.none,
              keyboardType: TextInputType.number,
              cursorColor: const Color(0xFFCC18CA),
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
    
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(16.r),
                fieldHeight: 64.h,
                fieldWidth: 64.w,
    
                activeColor: Colors.transparent,
                inactiveColor: Colors.transparent,
                selectedColor: Colors.transparent,
    
                activeFillColor: const Color(0xFFCC18CA).withOpacity(0.25),
                selectedFillColor: const Color(0xFFCC18CA).withOpacity(0.35),
                inactiveFillColor: const Color(0xFFCC18CA).withOpacity(0.15),
                borderWidth: 0,
              ),
    
              enableActiveFill: true,
              boxShadows: const [],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    
              animationDuration: const Duration(milliseconds: 200),
              controller: otpController,
              appContext: context,
              onChanged: (value) {},
              onCompleted: (value) {
                debugPrint("OTP: $value");
              },
            ),
            SizedBox(height: 40.h),
    
            // Submit Button with Loading
            CustomButton(
              onPressed: _submitOtp,
              buttonName: 'Submit',
              isLoading: _inProgress,
            ),
    
            SizedBox(height: 30.h),
    
            // Resend Code
            Center(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15.sp),
                  text: "Didn't receive the code? ",
                  children: [
                    TextSpan(
                      text: 'Resend Again',
                      style: const TextStyle(
                        color: Color(0xFF9810FA),
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _inProgress ? null : _resendOtp,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      final otpVerifyCtrl =
          Provider.of<OtpVerifyController>(context, listen: false);

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
            context, LogInScreen.name, (predicate) => false);
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