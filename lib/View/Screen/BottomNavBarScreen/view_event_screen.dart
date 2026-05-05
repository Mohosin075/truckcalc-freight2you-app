import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart'
    show ThemeProvider;
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
import 'package:gathering_app/View/Widgets/CustomButton.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key});

  static const String name = '/view-event-screen';

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, controller, child) => GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 36.r,
                        width: 36.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: controller.isDarkMode
                              ? const Color(0xFF3E043F)
                              : const Color(0xFF686868),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Image.asset('assets/images/cross_icon.png'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //start column
            Row(
              children: [
                SizedBox(
                  height: 50.h,
                  width: 50.w,
                  child: Image.asset('assets/images/fire_icon.png'),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bar Rebel',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 15.h,
                          width: 15.w,
                          child: Image.asset('assets/images/square.png'),
                        ),
                        SizedBox(width: 10.w),
                        Text('Official Gathering Location'),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.h),
            CircularPercentIndicator(
              radius: 80.r,
              lineWidth: 16,
              percent: 82 / 100,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    "HOT",
                    style: TextStyle(
                      fontSize: 23.sp.clamp(23, 25),
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE77534),
                    ),
                  ),
                  Text(
                    "82",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 40.sp.clamp(40, 50),
                    ),
                  ),
                  Text(
                    "Steady crowd",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              linearGradient: LinearGradient(
                colors: [
                  Color(0xFF201841),
                  Color(0xFF9E3C3C),
                  Color(0xFFE77534),
                ],
              ),
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              arcType: ArcType.HALF,
              // অর্ধবৃত্ত
              reverse: false,
              animation: true,
              animationDuration: 1000,
            ),

            SizedBox(height: 20.h),
            Consumer<ThemeProvider>(
              builder: (context, controller, child) => Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.h,
                          child: Image.asset(
                            'assets/images/person.png',
                            color: controller.isDarkMode
                                ? Color(0xFFFAFAFA)
                                : Color(0xFF000000),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text('Balanced Mix'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.h,
                          child: Image.asset(
                            'assets/images/single_person.png',
                            color: controller.isDarkMode
                                ? Color(0xFFFAFAFA)
                                : Color(0xFF000000),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text('25+ crowd'),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50.h,
                          child: Image.asset(
                            'assets/images/clock_icon.png',
                            color: controller.isDarkMode
                                ? Color(0xFFFAFAFA)
                                : Color(0xFF000000),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text('10min entry'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[300],
              ),
              child: Center(child: Icon(Icons.play_arrow)),
            ),
            SizedBox(height: 20.h),

            Row(
              children: [
                SizedBox(
                  width: 120.w,
                  child: CustomButton(
                    buttonName: 'Interested',
                    onPressed: () {
                      showCustomSnackBar(
                        context: context,
                        message: "Marked as Interested!",
                        isError: false,
                      );
                    },
                  ),
                ),
                SizedBox(width: 20.w),
                Container(
                  width: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Implement like/rating functionality
                    },
                    icon: Icon(Icons.thumb_up_alt_outlined),
                  ),
                ),
                SizedBox(width: 10.w),

                Container(
                  width: 60.w,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Implement dislike/rating functionality
                    },
                    icon: Icon(Icons.thumb_down_alt_outlined),
                  ),
                ),
              ],
            ),

            //end column body
          ],
        ),
      ),
    );
  }
}
