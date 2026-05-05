import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildUserInfo(),
                SizedBox(height: 20.h),
                _buildEditForm(),
                SizedBox(height: 16.h),
                _buildGradientButton('View All History', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                }),
                SizedBox(height: 16.h),
                _buildSubscriptionCard(context),
                SizedBox(height: 16.h),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.grey[800],
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(color: Color(0xFF1A237E), shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Text('Shahriar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('123456789', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildTextField('Full name', 'ssssssssss'),
          SizedBox(height: 16.h),
          _buildTextField('Email', 'ssssssssss'),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00D193)]),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              child: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subscription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Free Trial', style: TextStyle(color: Colors.white70)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10.r)),
                child: const Text('5d left', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: const Text('View Plans', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: const Text('Export Data', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        Text(value, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white30, fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(colors: [Color(0xFFFBC02D), Color(0xFF00D193)]),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            fillColor: Colors.white.withOpacity(0.05),
            filled: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.white10)),
          ),
        ),
      ],
    );
  }
}
