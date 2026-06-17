import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/bottom_nav_bar.dart';
import 'package:truckcalc/View/Screen/authentication_screen/forgot_pass_screen.dart';
import 'package:truckcalc/View/Screen/authentication_screen/sign_up_screen.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/app_logo.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Widgets/auth_textFormField.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';
import 'package:provider/provider.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});
  static const String name = '/log-in';

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      context: context,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, BottomNavBarScreen.name);
      } else {
        showCustomSnackBar(
          context: context,
          message: "Login failed! Please check your credentials.",
          isError: true,
        );
      }
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
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter email';
                          return null;
                        },
                      ),
                      AuthTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: '••••••••',
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Enter password';
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        buttonName: 'Sign in',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                      SizedBox(height: 12.h),
                      CustomButton(
                        buttonName: 'Forgot password?',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        onPressed: () {
                          Navigator.pushNamed(context, ForgotPassScreen.name);
                        },
                      ),
                      SizedBox(height: 24.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, SignUpScreen.name);
                        },
                        child: Text(
                          'New here? Create account',
                          style: TextStyle(
                            color: const Color(0xFF4C86FF),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
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
}
