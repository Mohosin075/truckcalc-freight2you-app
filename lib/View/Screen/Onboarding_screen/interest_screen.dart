import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/widget_controller/interestScreenController.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});
  static const String name = 'interest-screen';

  static final List<Map<String, dynamic>> interestItems = [
    {'icon': "assets/images/music_icon.png", 'name': 'Bars & Lounges'},
    {'icon': "assets/images/nightlife_icon.png", 'name': 'Party Spots'},
    {'icon': "assets/images/concerts_icon.png", 'name': 'Live DJs / Music'},
    {'icon': "assets/images/foodandDrinks_icon.png", 'name': 'Rooftops & Views'},
    {'icon': "assets/images/comedy_icon.png", 'name': 'Happy Hour'},
    {'icon': "assets/images/art_culture_icon.png", 'name': 'Day Parties'},
    {'icon': "assets/images/wellness_icon.png", 'name': 'Sports Bars'},
    {'icon': "assets/images/networking_icon.png", 'name': 'Hookah Lounges'},
    {'icon': "assets/images/networking_icon.png", 'name': 'Upscale / VIP'},
    {'icon': "assets/images/networking_icon.png", 'name': 'Late-Night Food'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text('What interests you?', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              Text('Select categories to personalize your feed', style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Consumer<InterestScreenController>(
                    builder: (context, controller, child) {
                      return GridView.builder(
                        itemCount: interestItems.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.3, crossAxisSpacing: 12, mainAxisSpacing: 12),
                        itemBuilder: (context, index) {
                          final isSelected = controller.selectedItems.contains(index);
                          return GestureDetector(
                            onTap: () => controller.toggleSelection(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(isSelected ? 0.1 : 0.03),
                                borderRadius: BorderRadius.circular(15.r),
                                border: Border.all(color: isSelected ? const Color(0xFF00D193) : Colors.white10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(interestItems[index]['icon'], height: 30.h, color: Colors.white),
                                  SizedBox(height: 8.h),
                                  Text(interestItems[index]['name'], style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Consumer<InterestScreenController>(
                  builder: (context, controller, child) {
                    return CustomButton(
                      buttonName: controller.selectedItemCount > 0 ? 'Continue' : 'Skip',
                      onPressed: () {
                        GetStorage().write('hasSeenOnboarding', true);
                        Navigator.pushNamed(context, LogInScreen.name);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
