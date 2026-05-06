import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/sign_up_controller.dart';
import 'package:gathering_app/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:gathering_app/View/Screen/authentication_screen/verify_account.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:gathering_app/View/Widgets/auth_textFormField.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const String name = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final signUpController = Provider.of<SignUpController>(context, listen: false);
    final success = await signUpController.signUp(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        showCustomSnackBar(
          context: context,
          message: "Account created successfully! Please verify your email.",
          isError: false,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyAccount(email: _emailController.text.trim()),
          ),
        );
      } else {
        showCustomSnackBar(
          context: context,
          message: signUpController.errorMessage ?? "Registration failed!",
          isError: true,
        );
      }
    }
  }

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
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Text(
                'Create account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40.h),
              const Text(
                'Start with a free 7-day trial — no credit card required',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF00D193), fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 30.h),
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
                        controller: _nameController,
                        labelText: 'Full name',
                        hintText: 'Your name',
                        validator: (v) => v!.isEmpty ? 'Enter name' : null,
                      ),
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Enter email' : null,
                      ),
                      AuthTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Min 6 characters',
                        isPassword: true,
                        validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: _isLoading ? null : _handleSignUp,
                        child: Container(
                          width: double.infinity,
                          height: 50.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF004D40), Color(0xFF00D193)],
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Create account',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, LogInScreen.name),
                child: const Text(
                  'Back to login',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
