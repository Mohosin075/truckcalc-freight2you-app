import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:gathering_app/View/Widgets/auth_textFormField.dart';

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
                      ),
                      AuthTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      AuthTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Min 6 characters',
                        isPassword: true,
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
                            // Proceed to main app or verification
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Text('Create account'),
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
