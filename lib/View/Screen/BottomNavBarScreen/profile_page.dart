import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:gathering_app/View/Widgets/CustomButton.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/history_page.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/subscription_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('Log out', style: TextStyle(color: const Color(0xFFE57373), fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildUserInfo(),
                SizedBox(height: 24.h),
                _buildEditForm(),
                SizedBox(height: 12.h),
                CustomButton(
                  buttonName: 'View All History',
                  isYellowGradient: true,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                  },
                ),
                SizedBox(height: 12.h),
                _buildSubscriptionCard(context),
                SizedBox(height: 12.h),
                _buildStatsSection(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7E57C2), width: 2),
              ),
              child: CircleAvatar(
                radius: 40.r,
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: Color(0xFF3F51B5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_note, color: Colors.white, size: 16.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text('Shahriar', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        Text('123456789', style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _buildTextField('Full name', 'ssssssssss'),
          SizedBox(height: 12.h),
          _buildTextField('Email', 'ssssssssss'),
          SizedBox(height: 20.h),
          const CustomButton(
            buttonName: 'Save changes',
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subscription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Free Trial', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F), 
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('5d left', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildOutlineButton('View Plans', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                }),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOutlineButton('Export Data', () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('3', 'Calculations'),
              _buildStatItem('5d', 'Plan left'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        Container(
          height: 45.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF081414).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white10),
          ),
          alignment: Alignment.centerLeft,
          child: Text(hint, style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
        ),
      ],
    );
  }
}
