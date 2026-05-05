import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Utils/getStartedData.dart';
import 'package:gathering_app/View/Screen/Onboarding_screen/interest_screen.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../Widgets/CustomButton.dart';

class GetStartScreen extends StatefulWidget {
  const GetStartScreen({super.key});

  static const String name = 'get-start-screen';

  @override
  State<GetStartScreen> createState() => _GetStartScreenState();
}

int currentPage = 0;

class _GetStartScreenState extends State<GetStartScreen> {
  final PageController _controller = PageController();

  void nextPage() {
    if (currentPage < getStartedContent.getStartedData.length - 1) {
      currentPage++;
      _controller.animateToPage(
        currentPage,
        duration: const Duration(microseconds: 1),
        curve: Curves.easeInOut,
      );
      setState(() {});
    } else {
      debugPrint('clicked');
      Navigator.pushNamed(context, InterestScreen.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Consumer<ThemeProvider>(
                  builder: (context, controller, child) => PageView.builder(
                    itemCount: getStartedContent.getStartedData.length,
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20.h),
                          Image.asset(
                            getStartedContent.getStartedData[index].icon,
                            color: controller.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            height: 48.h,
                          ),
                          SizedBox(height: 25.h),
                          Text(
                            getStartedContent.getStartedData[index].title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              getStartedContent
                                  .getStartedData[index]
                                  .subtitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFA0A0B0),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              GestureDetector(
                onTap: () => nextPage(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomButton(buttonName: 'Get Started'),
                ),
              ),
              SizedBox(height: 15.h),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: getStartedContent.getStartedData.length,
                  effect: const SlideEffect(
                    activeDotColor: Colors.purple,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
