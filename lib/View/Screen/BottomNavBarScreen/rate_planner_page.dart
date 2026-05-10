import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

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
                      style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showCustomSnackBar(context: context, message: "Rate plan saved!", isError: false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D193),
                        minimumSize: Size(80.w, 36.h),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                SizedBox(height: 16.h),
                _buildEarningsSplitCard(),
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
        color: const Color(0xFF021C1C),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WEEKLY TARGETS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGoalSettingsCard() {
    return _buildSectionCard(
      title: 'Goal Settings',
      child: Column(
        children: [
          _buildInputField(r'Desired Weekly Profit ($)', '1500'),
          _buildInputField(r'Cost Per Mile ($)', '0.50'),
          _buildInputField(r'Deadhead Pay Per Mile ($)', '0.25'),
          Row(
            children: [
              Expanded(child: _buildInputField('Desired # of Days/Week', '5')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Desired Max Miles/Day', '500')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedTargetsCard() {
    return _buildSectionCard(
      title: 'Calculated Targets',
      child: Column(
        children: [
          _buildDarkResultBox('LOADED MILES NEEDED PER WEEK', '0 miles', isGlow: true),
          SizedBox(height: 12.h),
          _buildDarkResultBox('MINIMUM TARGET RATE PER MILE', r'$0.00', isGlow: true),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildResultSubBox('Total Revenue', r'$0.00')),
              SizedBox(width: 16.w),
              Expanded(child: _buildResultSubBox('Total Cost', r'$0.00')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadheadSuggestionsCard() {
    return _buildSectionCard(
      title: 'Deadhead Suggestions',
      child: Row(
        children: [
          Expanded(child: _buildResultSubBox('Max DH Per Day', '0 mi')),
          SizedBox(width: 16.w),
          Expanded(child: _buildResultSubBox('Max DH Per Week', '0 mi')),
        ],
      ),
    );
  }

  Widget _buildEarningsSplitCard() {
    return _buildSectionCard(
      title: 'Earnings Split',
      child: Column(
        children: [
          _buildInputField('Driver Percentage (%)', '100'),
          SizedBox(height: 16.h),
          _buildSplitItem('DRIVER', '100.0%', r'$0.00'),
          SizedBox(height: 12.h),
          _buildSplitItem('OWNER', '0.0%', r'$0.00', color: const Color(0xFF4C86FF)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSplitItem(String label, String percent, String value, {Color color = const Color(0xFF00D193)}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF081414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(percent, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              Text(value, style: TextStyle(color: color, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultSubBox(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF081414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDarkResultBox(String label, String value, {bool isGlow = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isGlow ? const Color(0xFF021C1C) : const Color(0xFF081414),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isGlow ? const Color(0xFF00D193).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isGlow ? const Color(0xFF00D193) : Colors.white70,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        TextField(
          style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF00D193))),
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
