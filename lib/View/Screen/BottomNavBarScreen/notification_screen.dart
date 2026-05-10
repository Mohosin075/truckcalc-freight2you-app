import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/notification_controller.dart';
import 'package:truckcalc/View/Theme/theme_provider.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:provider/provider.dart';

import '../../Widgets/notification_container.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const String name = 'notification-screen';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationController>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
              Text(
                'Stay updated with your events',
                style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, controller, child) => GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.only(right: 18.w),
                height: 36.r,
                width: 36.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Image.asset('assets/images/cross_icon.png', color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: Consumer<NotificationController>(
          builder: (context, notificationController, child) {
          if (notificationController.inProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationController.errorMessage != null) {
            return Center(
              child: Text(
                notificationController.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (notificationController.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: notificationController.notifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          notificationController.notifications[index];
                      return NotificationContainer(
                        notification: notification,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: GestureDetector(
                    onTap: () async {
                      bool success =
                          await notificationController.markAllAsRead();
                      if (success) {
                        notificationController.fetchNotifications();
                      }
                    },
                    child: CustomButton(buttonName: 'Mark all as read'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

