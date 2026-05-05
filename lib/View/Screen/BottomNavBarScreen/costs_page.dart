import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';

class CostsPage extends StatelessWidget {
  const CostsPage({super.key});

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
                      'CPM Calculator',
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
                _buildTotalOperatingCostHeader(),
                SizedBox(height: 20.h),
                _buildSectionHeader('1. WEEKLY FIXED COSTS'),
                _buildFixedCostsSection(),
                SizedBox(height: 20.h),
                _buildSectionHeader('2. VARIABLE COSTS'),
                _buildVariableCostsSection(),
                SizedBox(height: 20.h),
                _buildSectionHeader('3. TOTAL OPERATING COST'),
                _buildTotalOperatingCostSection(),
                SizedBox(height: 20.h),
                _buildConversionTip(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalOperatingCostHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL OPERATING COST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildSummaryItem('Weekly Total', r'$0.00'),
              SizedBox(width: 40.w),
              _buildSummaryItem('True CPM', r'$0.00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFC2185B)]),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFixedCostsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
      ),
      child: Column(
        children: [
          _buildInputField('Weekly Insurance Payment', '0.00'),
          _buildInputField('Weekly Truck Payment', '0.00'),
          _buildInputField('Weekly Escrow Contribution', '0.00'),
          _buildInputField('Weekly Repair Savings', '0.00'),
          _buildInputField('Weekly Self/Driver Pay', '0.00'),
          _buildInputField('Weekly Permits/Subscriptions', '0.00'),
          _buildInputField('Other Weekly Costs', '0.00'),
          SizedBox(height: 16.h),
          _buildResultBox('TOTAL WEEKLY FIXED COSTS', r'$0.00'),
        ],
      ),
    );
  }

  Widget _buildVariableCostsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
      ),
      child: Column(
        children: [
          _buildInputField('Miles Driven Per Week', '2500'),
          Row(
            children: [
              Expanded(child: _buildInputField('Average MPG', '6.5')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Avg Fuel Price (\$ /gal)', '3.50')),
            ],
          ),
          _buildResultBox('WEEKLY FUEL COST', r'$0.00'),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildInputField('Oil Changes/Year', '12')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Cost Per Oil Change', '300')),
            ],
          ),
          _buildResultBox('WEEKLY OIL CHANGE COST', r'$0.00'),
          SizedBox(height: 16.h),
          _buildInputField('Tire Cost Per Year', '5000'),
          _buildResultBox('WEEKLY TIRE COST', r'$0.00'),
          SizedBox(height: 16.h),
          _buildInputField('Maintenance Cost Per Year', '8000'),
          _buildResultBox('WEEKLY MAINTENANCE COST', r'$0.00'),
          SizedBox(height: 16.h),
          _buildResultBox('TOTAL WEEKLY VARIABLE COSTS', r'$0.00', isLarge: true),
        ],
      ),
    );
  }

  Widget _buildTotalOperatingCostSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildGraySummaryBox('Total Fixed', r'$0.00')),
              SizedBox(width: 16.w),
              Expanded(child: _buildGraySummaryBox('Total Variable', r'$0.00')),
            ],
          ),
          SizedBox(height: 12.h),
          _buildGraySummaryBox('TOTAL WEEKLY OPERATING COST', r'$0.00', isLarge: true),
          SizedBox(height: 12.h),
          _buildGraySummaryBox('Miles Driven Per Week', '0 miles'),
          SizedBox(height: 12.h),
          _buildGraySummaryBox('TRUE COST PER MILE', r'$0.00', isLarge: true),
        ],
      ),
    );
  }

  Widget _buildConversionTip() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'TO CONVERT MONTHLY PAYMENTS TO WEEKLY, DIVIDE BY 4.33',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox(String label, String value, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: isLarge ? 20.sp : 18.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraySummaryBox(String label, String value, {bool isLarge = false}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: isLarge ? 20.sp : 16.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
          child: Text(label, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500)),
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
