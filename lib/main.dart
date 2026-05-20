import 'package:firebase_core/firebase_core.dart';
import 'package:truckcalc/firebase_options.dart';
import 'package:truckcalc/Service/PushNotification/notification_service.dart';
import 'package:truckcalc/Service/Controller/chat_controller.dart';
import 'package:truckcalc/Service/Controller/bottom_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/Service/Controller/email_verify_controller.dart';
import 'package:truckcalc/Service/Controller/event_details_controller.dart';
import 'package:truckcalc/Service/Controller/forgot_pass_controller.dart';
import 'package:truckcalc/Service/Controller/getAllEvent_controller.dart';
import 'package:truckcalc/Service/Controller/log_in_controller.dart';
import 'package:truckcalc/Service/Controller/other_user_profile_controller.dart';
import 'package:truckcalc/Service/Controller/otp_verify_controller.dart';
import 'package:truckcalc/Service/Controller/profile_page_controller.dart';
import 'package:truckcalc/Service/Controller/live_chat_controller.dart';
import 'package:truckcalc/Service/Controller/sign_up_controller.dart';
import 'package:truckcalc/View/Theme/theme_provider.dart';
import 'package:truckcalc/View/widget_controller/interestScreenController.dart';
import 'package:truckcalc/View/view_controller/saved_event_controller.dart';
import 'package:truckcalc/Service/Controller/notification_controller.dart';
import 'package:truckcalc/Service/Controller/create_event_controller.dart';
import 'package:truckcalc/Service/Controller/user_event_controller.dart';
import 'package:truckcalc/Service/Controller/map_controller.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/Service/Controller/subscription_controller.dart';
import 'package:truckcalc/Service/Controller/iap_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Utils/app_utils.dart';

import 'package:truckcalc/Service/Api%20service/network_caller.dart';
import 'Core/AppRoute/app_route.dart';
import 'View/Screen/Onboarding_screen/splash_screen.dart';
import 'View/Theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkCaller.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await NotificationService.init().timeout(
      const Duration(seconds: 8),
      onTimeout: () => debugPrint('Notification initialization timed out'),
    );
  } catch (e) {
    debugPrint('Notification initialization error: $e');
  }

  // Run heavy initializations and await them
  await GetStorage.init();

  final themeProvider = ThemeProvider();
  try {
    await themeProvider.init();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final p = ProfileController();
            p.initialize();
            return p;
          },
        ),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => InterestScreenController()),
        ChangeNotifierProvider(create: (_) => SavedEventController()),
        ChangeNotifierProvider(create: (_) => SignUpController()),
        ChangeNotifierProvider(create: (_) => LogInController()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordController()),
        ChangeNotifierProvider(create: (_) => EmailVerifyController()),
        ChangeNotifierProvider(create: (_) => GetAllEventController()),
        ChangeNotifierProvider(create: (_) => EventDetailsController()),
        ChangeNotifierProvider(create: (_) => OtherUserProfileController()),
        ChangeNotifierProvider(create: (_) => OtpVerifyController()),
        ChangeNotifierProvider(
          create: (_) {
            final c = AuthController();
            c.initialize();
            return c;
          },
        ),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => BottomNavController()),
        ChangeNotifierProvider(create: (_) => LiveChatController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => CreateEventController()),
        ChangeNotifierProvider(
          create: (_) {
            final m = MapController();
            m.init();
            return m;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserEventController()),
        ChangeNotifierProvider(create: (_) => CalculationController()),
        ChangeNotifierProvider(create: (_) => SubscriptionController()),
        ChangeNotifierProvider(create: (_) => IapController()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(439, 956),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                navigatorKey: AppUtils.navigatorKey,
                scaffoldMessengerKey: AppUtils.scaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                title: 'TruckCalc',
                theme: ThemeColor.lightMode,
                darkTheme: ThemeColor.darkMode,
                themeMode: ThemeMode.dark, // Force dark mode as per design
                initialRoute: SplashScreen.name,
                routes: AppRoutes.routes,
              );
            },
          );
        },
        child: const SplashScreen(),
      ),
    );
  }
}
