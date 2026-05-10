import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key});
  static const String name = '/view-event-screen';
  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/images/fire_icon.png', height: 40.h),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bar Rebel', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      const Text('Official Gathering Location', style: TextStyle(color: Colors.white60)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              CircularPercentIndicator(
                radius: 80.r,
                lineWidth: 12,
                percent: 0.82,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("82", style: TextStyle(color: Colors.white, fontSize: 40.sp, fontWeight: FontWeight.bold)),
                    const Text("Steady crowd", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                linearGradient: const LinearGradient(colors: [Color(0xFFE77534), Color(0xFF00D193)]),
                backgroundColor: Colors.white10,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              SizedBox(height: 30.h),
              Container(
                height: 200.h,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15.r)),
                child: const Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 50)),
              ),
              SizedBox(height: 30.h),
              CustomButton(buttonName: 'Interested', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
