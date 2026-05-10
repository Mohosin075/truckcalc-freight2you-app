import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Utils/getStartedData.dart';
import 'package:truckcalc/View/Screen/Onboarding_screen/interest_screen.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GetStartScreen extends StatefulWidget {
  const GetStartScreen({super.key});
  static const String name = 'get-start-screen';
  @override
  State<GetStartScreen> createState() => _GetStartScreenState();
}

class _GetStartScreenState extends State<GetStartScreen> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: getStartedContent.getStartedData.length,
                controller: _controller,
                onPageChanged: (i) => setState(() => currentPage = i),
                itemBuilder: (context, index) {
                  final data = getStartedContent.getStartedData[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(data.icon, height: 120.h, color: Colors.white),
                      SizedBox(height: 40.h),
                      Text(data.title, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(data.subtitle, style: TextStyle(color: Colors.white60, fontSize: 16.sp), textAlign: TextAlign.center),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomButton(
                buttonName: currentPage == getStartedContent.getStartedData.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (currentPage < getStartedContent.getStartedData.length - 1) {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    Navigator.pushNamed(context, InterestScreen.name);
                  }
                },
              ),
            ),
            SizedBox(height: 20.h),
            SmoothPageIndicator(
              controller: _controller,
              count: getStartedContent.getStartedData.length,
              effect: const SlideEffect(activeDotColor: Color(0xFF00D193), dotColor: Colors.white24, dotHeight: 8, dotWidth: 8),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
