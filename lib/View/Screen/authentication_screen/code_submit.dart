import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/forgot_pass_controller.dart';
import 'package:gathering_app/View/Screen/authentication_screen/new_password_screen.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../Widgets/CustomButton.dart';
import '../../Widgets/appbar.dart';


class CodeSubmit extends StatefulWidget {

   CodeSubmit({super.key,});
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: common_appbar(titleName: 'Forgot Password'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Code Submit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Enter the 6-Digit code sent to you at\n${forgotPassController.savedEmail}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
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
              SizedBox(height: 20.h),
              Consumer<ForgotPasswordController>(
                builder: (context, forgotController, child) {
                  return CustomButton(
                    buttonName: 'Submit',
                    isLoading: forgotController.inProgress,
                    onPressed: onTapSubmit,
                  );
                },
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    text: "Don't receive code? ",
                    children: [
                      TextSpan(
                        text: 'Resend Again',
                        style: TextStyle(color: Color(0xFF9810FA)),
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
    final forgotPassController = Provider.of<ForgotPasswordController>(context, listen: false);
    bool isSuccess = await forgotPassController.forgotPassword(forgotPassController.savedEmail);
    if (isSuccess && mounted) {
      showCustomSnackBar(context: context, message: 'Code resent to ${forgotPassController.savedEmail}', isError: false);
    } else if (mounted) {
      showCustomSnackBar(context: context, message: forgotPassController.errorMessage ?? 'Resend failed');
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
