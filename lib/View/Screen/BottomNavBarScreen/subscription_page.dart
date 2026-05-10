import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subscription',
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBC02D).withValues(alpha: 0.8), 
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text('Trial', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF880E4F), Color(0xFFE91E63)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          'Your free trial ends in 5 days. Upgrade to keep full access.',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildPlanCard('Free Trial', 'Free', '/7 days', [
                        '10 calculations/day',
                        'Basic history',
                        'CSV export',
                      ]),
                      SizedBox(height: 16.h),
                      _buildPlanCard('Pro', r'$19.99', '/month', [
                        'Unlimited calculations',
                        'Full history',
                        'PDF & CSV export',
                        'Priority support',
                      ], showButton: true, buttonText: 'Select Pro'),
                      SizedBox(height: 16.h),
                      _buildPlanCard('Annual', r'$119.99', '/year', [
                        'Unlimited calculations',
                        'Full history',
                        'PDF & CSV export',
                        'Priority support',
                      ], showButton: true, buttonText: 'Select Annual', isBestValue: true),
                      SizedBox(height: 100.h),
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

  Widget _buildPlanCard(String title, String price, String period, List<String> features, {bool showButton = false, String? buttonText, bool isBestValue = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: price, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                        TextSpan(text: period, style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              ...features.map((f) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: const Color(0xFF00D193), size: 16.sp),
                        SizedBox(width: 12.w),
                        Text(f, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14.sp)),
                      ],
                    ),
                  )),
              if (showButton) ...[
                SizedBox(height: 20.h),
                CustomButton(
                  buttonName: buttonText!,
                  isYellowGradient: true,
                  onPressed: () {},
                ),
              ],
            ],
          ),
          if (isBestValue)
            Positioned(
              top: -10.h,
              right: -25.w,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2C255),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
