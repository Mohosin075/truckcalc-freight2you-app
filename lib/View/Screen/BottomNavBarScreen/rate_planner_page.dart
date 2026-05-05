import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';

class RatePlannerPage extends StatelessWidget {
  const RatePlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate Planner',
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D193),
                        minimumSize: Size(80.w, 36.h),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildWeeklyTargetsCard(),
                SizedBox(height: 16.h),
                _buildGoalSettingsCard(),
                SizedBox(height: 16.h),
                _buildCalculatedTargetsCard(),
                SizedBox(height: 16.h),
                _buildDeadheadSuggestionsCard(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyTargetsCard() {
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
          const Text('WEEKLY TARGETS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildTargetItem('Miles Needed', '0'),
              SizedBox(width: 40.w),
              _buildTargetItem('Min Rate/Mile', r'$0.00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGoalSettingsCard() {
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
          const Text('Goal Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _buildInputField(r'Desired Weekly Profit ($)', '1500'),
          SizedBox(height: 12.h),
          _buildInputField(r'Cost Per Mile ($)', '0.50'),
          SizedBox(height: 12.h),
          _buildInputField(r'Deadhead Pay Per Mile ($)', '0.25'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildInputField('Desired # of Days Per Week', '5')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Desired Max Miles Per Day', '500')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedTargetsCard() {
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
          const Text('Calculated Targets', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          _buildLargeSummaryBox('LOADED MILES NEEDED PER WEEK', '0 miles'),
          SizedBox(height: 12.h),
          _buildLargeSummaryBox('MINIMUM TARGET RATE PER MILE', r'$0.00'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildSummaryBox('Total Revenue', r'$0.00')),
              SizedBox(width: 16.w),
              Expanded(child: _buildSummaryBox('Total Cost', r'$0.00')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadheadSuggestionsCard() {
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
          const Text('Deadhead Suggestions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildSummaryBox('Max DH Per Day', '0 mi')),
              SizedBox(width: 16.w),
              Expanded(child: _buildSummaryBox('Max DH Per Week', '0 mi')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeSummaryBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: const Color(0xFF00D193), fontSize: 10.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Color(0xFF00D193))),
          ),
        ),
      ],
    );
  }
}
