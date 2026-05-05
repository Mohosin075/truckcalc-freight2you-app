import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/notification_model.dart';
import 'package:gathering_app/Service/Controller/notification_controller.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

class NotificationContainer extends StatelessWidget {
  final NotificationData notification;
  const NotificationContainer({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, NotificationController>(
      builder: (context, themeController, notificationController, child) =>
          GestureDetector(
            onTap: () {
              if (notification.sId != null) {
                notificationController.markAsRead(notification.sId!);
              }
            },
            child: SizedBox(
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    width: 1,
                    color: Color(0xFFCC18CA).withOpacity(0.15),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    height: 10.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: notification.isRead == true
                          ? Colors.grey
                          : Colors.pink,
                    ),
                  ),
                  title: Text(
                    notification.title ?? 'No Title',
                    style: TextStyle(
                      fontWeight: notification.isRead == true
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: themeController.isDarkMode
                          ? Color(0xFFF0F0F5)
                          : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.content ?? '',
                        style: TextStyle(
                          color: themeController.isDarkMode
                              ? Color(0xFFF0F0F5).withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: themeController.isDarkMode
                              ? Color(0xFFF0F0F5).withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final DateTime date = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
