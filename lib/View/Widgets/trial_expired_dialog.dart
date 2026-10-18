import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/subscription_page.dart';

void showTrialExpiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF13221C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: Color(0xFF00D193), width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: const Color(0xFFFF5252), size: 24.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Free Trial Expired',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Your 7-day free trial has concluded. Please upgrade to Pro or Annual to keep creating unlimited calculations and access all features.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Later',
              style: TextStyle(color: Colors.white60, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D193),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionPage()),
              );
            },
            child: Text(
              'Upgrade Now',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    },
  );
}
