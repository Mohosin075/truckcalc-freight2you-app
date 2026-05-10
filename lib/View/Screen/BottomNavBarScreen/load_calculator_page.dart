import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';

class LoadCalculatorPage extends StatelessWidget {
  const LoadCalculatorPage({super.key});

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
                      'Load Calculator',
                      style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showCustomSnackBar(context: context, message: "Load calculation saved!", isError: false);
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
                _buildSummaryHeader(),
                SizedBox(height: 16.h),
                _buildRevenueInputsCard(),
                SizedBox(height: 16.h),
                _buildDeadheadBonusCard(),
                SizedBox(height: 16.h),
                _buildSummaryTableCard(),
                SizedBox(height: 16.h),
                _buildDriverProfitCard(),
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

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF021C1C),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOAD CALCULATOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildSummaryItem('Total Revenue', r'$0.00'),
              SizedBox(width: 40.w),
              _buildSummaryItem('Total Profit', r'$0.00'),
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
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRevenueInputsCard() {
    return _buildSectionCard(
      title: 'Revenue Inputs',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField('Base Rate Per Mile', '0.00')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Fuel Surcharge/Mile', '0.00')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildInputField('Loaded Miles', '0')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('Tolls (\$)', '0.00')),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDarkResultBox(r'Total FSC $', r'$0.00'),
        ],
      ),
    );
  }

  Widget _buildDeadheadBonusCard() {
    return _buildSectionCard(
      title: 'Deadhead & Bonus',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField('DH Miles', '0')),
              SizedBox(width: 16.w),
              Expanded(child: _buildInputField('DH Rate Per Mile', '0.00')),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDarkResultBox(r'Total DH $', r'$0.00'),
          SizedBox(height: 16.h),
          _buildInputField('Bonus/Accessorial Pay', '0.00'),
        ],
      ),
    );
  }

  Widget _buildSummaryTableCard() {
    return _buildSectionCard(
      title: 'Summary',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDarkResultBox('Total Revenue', r'$0.00', small: true)),
              SizedBox(width: 16.w),
              Expanded(child: _buildDarkResultBox('Total Miles', '0', small: true)),
            ],
          ),
          SizedBox(height: 12.h),
          _buildDarkResultBox('Compensation Per Mile', r'$0.00'),
        ],
      ),
    );
  }

  Widget _buildDriverProfitCard() {
    return _buildSectionCard(
      title: 'DRIVER PROFIT',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildLabelValue('Profit Per Mile', r'$0.00')),
              Expanded(child: _buildLabelValue('Cost Per Mile', r'$0.00')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildLabelValue('Total Profit', r'$0.00')),
              Expanded(child: _buildLabelValue('Total Cost', r'$0.00')),
            ],
          ),
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

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDarkResultBox(String label, String value, {bool small = false}) {
    return Container(
      width: double.infinity,
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
          Text(value, style: TextStyle(color: Colors.white, fontSize: small ? 16.sp : 18.sp, fontWeight: FontWeight.bold)),
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
      ],
    );
  }
}
