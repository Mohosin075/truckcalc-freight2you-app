import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Text(
                  'History',
                  style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search calculations...',
                    fillColor: Colors.white.withOpacity(0.05),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.white10)),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    _buildHistoryCard(
                      'Weekly Costs: Fixed \$34.00 + Variable \$22227.54',
                      '= Total: \$22261.54, CPM: \$1.00',
                      '4/24/2026, 2:18',
                    ),
                    _buildHistoryCard(
                      'Weekly Goal: \$2222222, 2 days',
                      '= Need 100mi @ \$22222.00/mi',
                      '4/24/2026, 2:18',
                    ),
                    _buildHistoryCard(
                      'Load: 22222222mi + 2222DH @ \$22222222/mi',
                      '= Revenue: \$543209888396296.00, Profit: \$543209888374074.00',
                      '4/24/2026, 2:18',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String header, String result, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(header, style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Text(result, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Text(time, style: TextStyle(color: Colors.white30, fontSize: 10.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8.r)),
            child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }
}
