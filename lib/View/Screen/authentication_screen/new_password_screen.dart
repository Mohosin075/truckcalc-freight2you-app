import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/forgot_pass_controller.dart';
import 'package:truckcalc/View/Screen/authentication_screen/forgot_pass_screen.dart';
import 'package:truckcalc/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/app_logo.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Widgets/auth_textFormField.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});
  static const String name = '/new-password-screen';

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Create New Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      AuthTextField(
                        controller: _newPassController,
                        labelText: 'New Password',
                        hintText: '••••••••',
                        isPassword: true,
                      ),
                      AuthTextField(
                        controller: _confirmPassController,
                        labelText: 'Confirm Password',
                        hintText: '••••••••',
                        isPassword: true,
                        validator: (value) {
                          if (value != _newPassController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        buttonName: 'Confirm',
                        onPressed: onTapConfirmButton,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    ForgotPassScreen.name,
                    (route) => false,
                  );
                },
                child: Text(
                  'Back',
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

  void onTapConfirmButton() async {
    if (_formKey.currentState!.validate()) {
      await createNewPassword();
    }
  }

  Future<void> createNewPassword() async {
    final forgotController = Provider.of<ForgotPasswordController>(
      context,
      listen: false,
    );

    bool isSuccess = await forgotController.forgotNewPassword(
      _newPassController.text.trim(),
      _confirmPassController.text.trim(),
    );

    if (mounted) {
      if (isSuccess) {
        showCustomSnackBar(
          context: context,
          message: "Password updated successfully!",
          isError: false,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          LogInScreen.name,
          (route) => false,
        );
      } else {
        showCustomSnackBar(
          context: context,
          message: forgotController.errorMessage ?? "Something went wrong",
        );
      }
    }
  }
}
