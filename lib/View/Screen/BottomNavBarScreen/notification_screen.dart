import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/notification_controller.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:gathering_app/View/Widgets/CustomButton.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 20.sp.clamp(20, 22),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Stay updated with your events',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey,
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
                  color: controller.isDarkMode
                      ? const Color(0xFF3E043F)
                      : const Color(0xFF686868),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Image.asset('assets/images/cross_icon.png'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationController>(
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
    );
  }
}

