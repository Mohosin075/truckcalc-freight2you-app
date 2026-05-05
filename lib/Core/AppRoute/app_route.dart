// View/app.dart
import 'package:flutter/material.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/bottom_nav_bar.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/details_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/notification_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/other_user_profile_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/user_chat_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/settings_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/saved_events_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/view_event_screen.dart';
import 'package:gathering_app/Model/ChatModel.dart';
import 'package:gathering_app/View/Screen/authentication_screen/code_send.dart';
import 'package:gathering_app/View/Screen/authentication_screen/code_submit.dart';
import 'package:gathering_app/View/Screen/authentication_screen/new_password_screen.dart';
import 'package:gathering_app/View/Screen/authentication_screen/verify_account.dart';
import '../../View/Screen/Onboarding_screen/get_start_screen.dart';
import '../../View/Screen/Onboarding_screen/interest_screen.dart';
import '../../View/Screen/Onboarding_screen/splash_screen.dart';
import '../../View/Screen/authentication_screen/forgot_pass_screen.dart';
import '../../View/Screen/authentication_screen/log_in_screen.dart';
import '../../View/Screen/authentication_screen/sign_up_screen.dart';

class AppRoutes {
  static const String splash = SplashScreen.name;
  static const String getStart = GetStartScreen.name;
  static const String interest = InterestScreen.name;
  static const String login = LogInScreen.name;
  static const String signup = SignUpScreen.name;
  static const String forgotPass = ForgotPassScreen.name;
  static const String codeSend = CodeSend.name;
  static const String codeSubmit = CodeSubmit.name;
  static const String bottomNavBar = BottomNavBarScreen.name;
  static const String notificationScreen = NotificationScreen.name;
  static const String userchatScreen = UserChatScreen.name;
  static const String detaisScreen = DetailsScreen.name;
  static const String viewEventScreen = ViewEventScreen.name;
  static const String newPassScreen = NewPasswordScreen.name;
  static const String verifyAccount = '/verify-account';

  static final routes = {
    splash: (context) => const SplashScreen(),
    getStart: (context) => const GetStartScreen(),
    interest: (context) => InterestScreen(),
    login: (context) => LogInScreen(),
    signup: (context) => const SignUpScreen(),
    forgotPass: (context) => const ForgotPassScreen(),
    codeSend: (context) => const CodeSend(),
    codeSubmit: (context) => CodeSubmit(),
    bottomNavBar: (context) => const BottomNavBarScreen(),
    notificationScreen: (context) => const NotificationScreen(),
    userchatScreen: (context) {
      final chat = ModalRoute.of(context)!.settings.arguments as ChatModel?;
      return UserChatScreen(chat: chat);
    },
    detaisScreen: (context) => const DetailsScreen(),
    viewEventScreen: (context) => const ViewEventScreen(),
    newPassScreen: (context) => NewPasswordScreen(),
    verifyAccount: (context) => VerifyAccount(email: ''),
    OtherUserProfileScreen.name: (context) {
      final userId = ModalRoute.of(context)!.settings.arguments as String;
      return OtherUserProfileScreen(userId: userId);
    },
    SettingsScreen.name: (context) => const SettingsScreen(),
    SavedEventsScreen.name: (context) => const SavedEventsScreen(),
  };
}
