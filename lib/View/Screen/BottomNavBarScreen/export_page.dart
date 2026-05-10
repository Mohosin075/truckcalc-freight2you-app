import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

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
                Text(
                  'Export',
                  style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00302E).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFF00D193).withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    '5 calculations ready to export',
                    style: TextStyle(color: Color(0xFF00D193), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildExportCard(
                  'CSV Export',
                  'For Excel & Sheets',
                  'Spreadsheet-friendly format. Opens in Excel, Google Sheets.',
                  'Download CSV',
                  Icons.insert_drive_file,
                ),
                SizedBox(height: 16.h),
                _buildExportCard(
                  'PDF Export',
                  'For printing & sharing',
                  'Formatted report for printing or sharing.',
                  'Download PDF',
                  Icons.picture_as_pdf,
                ),
                SizedBox(height: 30.h),
                Text(
                  'Preview',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                _buildPreviewSection(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportCard(String title, String subtitle, String desc, String btnText, IconData icon) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: const Color(0xFF00D193), size: 24),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  Text(subtitle, style: TextStyle(color: Colors.white38, fontSize: 11.sp)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(desc, style: TextStyle(color: Colors.white60, fontSize: 12.sp, height: 1.4)),
          SizedBox(height: 20.h),
          CustomButton(
            buttonName: btnText,
            isYellowGradient: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _previewItem('Weekly Costs: Fixed \$34.00 + Variable \$22227.54'),
          _previewItem('Weekly Goal: \$2222222, 2 days = Need 100mi'),
          _previewItem('Load: 22222222mi + 2222DH = Profit: \$543k'),
        ],
      ),
    );
  }

  Widget _previewItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.white38, fontSize: 11.sp, height: 1.5),
      ),
    );
  }
}
