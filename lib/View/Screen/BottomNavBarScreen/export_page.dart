import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';

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
                  style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF021C1C),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFF00D193).withOpacity(0.2)),
                  ),
                  child: Text(
                    '5 calculations ready to export',
                    style: TextStyle(color: const Color(0xFF00D193), fontWeight: FontWeight.bold, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildExportCard(
                  'CSV Export',
                  'For Excel & Sheets',
                  'Spreadsheet-friendly format. Opens in Excel, Google Sheets.',
                  'Download CSV',
                  Icons.insert_drive_file,
                  const Color(0xFF1A237E),
                ),
                SizedBox(height: 16.h),
                _buildExportCard(
                  'PDF Export',
                  'For printing & sharing',
                  'Formatted report for printing or sharing.',
                  'Download PDF',
                  Icons.picture_as_pdf,
                  const Color(0xFF311B92),
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

  Widget _buildExportCard(String title, String subtitle, String desc, String btnText, IconData icon, Color iconBg) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF081414).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.blueAccent, size: 24),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                  Text(subtitle, style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(desc, style: TextStyle(color: Colors.white70, fontSize: 12.sp, height: 1.4)),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: const LinearGradient(
                colors: [Color(0xFFFBC02D), Color(0xFF00D193)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                btnText,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ),
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
        color: const Color(0xFF081414).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _previewItem('Weekly Costs: Fixed \$34.00 + Variable \$22227.54 = Total: \$22261.54, CPM: \$1.00'),
          _previewItem('Weekly Goal: \$2222222, 2 days = Need 100mi @ \$22222.00/mi'),
          _previewItem('Load: 22222222mi + 2222DH @ \$22222222/mi = Revenue: \$543209888396296.00, Profit: \$543209888374074.00'),
          _previewItem('Load: 22222222mi + 0DH @ \$22222222/mi = Revenue: \$543209883456790.00, Profit: \$543209883456790.00'),
        ],
      ),
    );
  }

  Widget _previewItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Text(
        text,
        style: TextStyle(color: Colors.white60, fontSize: 11.sp, height: 1.6),
      ),
    );
  }
}
