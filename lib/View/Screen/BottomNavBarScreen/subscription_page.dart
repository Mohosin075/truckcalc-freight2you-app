import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';

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
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(10.r)),
                      child: const Text('Trial', style: TextStyle(color: Colors.orangeAccent, fontSize: 10)),
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
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Text(
                          'Your free trial ends in 5 days. Upgrade to keep full access.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                      SizedBox(height: 50.h),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: price, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                        TextSpan(text: period, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ...features.map((f) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Color(0xFF00D193), size: 16),
                        SizedBox(width: 8.w),
                        Text(f, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )),
              if (showButton) ...[
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(colors: [Color(0xFFFBC02D), Color(0xFF00D193)]),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    child: Text(buttonText!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
          if (isBestValue)
            Positioned(
              top: 0,
              right: -10,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  decoration: const BoxDecoration(color: Colors.orangeAccent),
                  child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
