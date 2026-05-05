import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/forgot_pass_controller.dart';
import 'package:gathering_app/View/Screen/authentication_screen/forgot_pass_screen.dart';
import 'package:gathering_app/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:gathering_app/View/Widgets/auth_textFormField.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, ForgotPassScreen.name, (route) => false);
                  },
                ),
              ),
              Text(
                'Create New Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
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
                          onPressed: onTapConfirmButton,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text('Confirm'),
                        ),
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

  void onTapConfirmButton() async {
    if (_formKey.currentState!.validate()) {
      await createNewPassword();
    }
  }

  Future<void> createNewPassword() async {
    final forgotController = Provider.of<ForgotPasswordController>(context, listen: false);

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
        Navigator.pushNamedAndRemoveUntil(context, LogInScreen.name, (route) => false);
      } else {
        showCustomSnackBar(
          context: context,
          message: forgotController.errorMessage ?? "Something went wrong",
        );
      }
    }
  }
}
