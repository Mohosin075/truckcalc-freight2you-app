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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search calculations...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    fillColor: Colors.white.withOpacity(0.05),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
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
                    _buildHistoryCard(
                      'Load: 22222222mi + 0DH @ \$22222222/mi',
                      '= Revenue: \$543209883456790.00, Profit: \$543209883456790.00',
                      '4/24/2026, 2:17',
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
        color: const Color(0xFF081414).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(header, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
                SizedBox(height: 10.h),
                Text(
                  result,
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6.h),
                Text(time, style: TextStyle(color: Colors.white24, fontSize: 10.sp)),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.close, color: Colors.redAccent, size: 18),
          ),
        ],
      ),
    );
  }
}
