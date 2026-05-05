import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:gathering_app/View/Widgets/CustomButton.dart';
import 'package:gathering_app/View/widget_controller/interestScreenController.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class InterestScreen extends StatelessWidget {
  InterestScreen({super.key});

  static const String name = 'interest-screen';

  final List<Map<String, dynamic>> interestItems = [
    {'icon': "assets/images/music_icon.png", 'name': 'Bars & Lounges'},
    {'icon': "assets/images/nightlife_icon.png", 'name': 'Party Spots'},
    {'icon': "assets/images/concerts_icon.png", 'name': 'Live DJs / Music'},
    {
      'icon': "assets/images/foodandDrinks_icon.png",
      'name': 'Rooftops & Views',
    },
    {'icon': "assets/images/comedy_icon.png", 'name': 'Happy Hour'},
    {'icon': "assets/images/art_culture_icon.png", 'name': 'Day Parties'},
    {'icon': "assets/images/wellness_icon.png", 'name': 'Sports Bars'},
    {'icon': "assets/images/networking_icon.png", 'name': 'Hookah Lounges'},
    {'icon': "assets/images/networking_icon.png", 'name': 'Upscale / VIP'},
        {'icon': "assets/images/networking_icon.png", 'name': 'Late-Night Food & Drinks'},

  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                'What interests you?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                'Select your favorite event types to personalize\nyour feed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<InterestScreenController>(
                  builder: (context, controller, child) {
                    return GridView.builder(
                      itemCount: interestItems.length,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected = controller.selectedItems.contains(
                          index,
                        );
                        var item = interestItems[index];
                        return GestureDetector(
                          onTap: () {
                            controller.toggleSelection(index);
                          },
                          child: Container(
                            // height: 187.h,width: 150.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFFCC18CA).withOpacity(
                                              0.25,
                                            ) // Dark mode border
                                          : const Color(
                                              0xFFE2E8F0,
                                            ), // Light mode border
                                      width: 1,
                                    ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 60.h,
                                        width: 60.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(
                                                      0xFFB026FF,
                                                    ), // deep purple
                                                    Color(0xFFFF006E), // darker
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : null,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Color(0xFFF1F3F5)
                                              : null,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            item['icon'],
                                            height: 31.h,
                                            width: 31.h,
                                            color: isSelected
                                                ? Colors.black
                                                : Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item['name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: isSelected
                                                ? Theme.of(context).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.grey
                                                : Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFB026FF),
                                    ),
                                  ),
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
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Consumer<InterestScreenController>(
                builder: (context, controller, child) {
                  if (controller.selectedItemCount == 0) {
                    return Text(
                      'Please select at least one item',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        // Mark onboarding as seen
                        GetStorage().write('hasSeenOnboarding', true);
                        //TODO: NAVIGATE LOG IN SCREEN
                        Navigator.pushNamed(context, LogInScreen.name);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: CustomButton(
                          buttonName:
                              'Continue (${controller.selectedItemCount} selected)',
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
