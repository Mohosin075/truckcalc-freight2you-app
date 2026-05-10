import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/load_calculator_page.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/rate_planner_page.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/costs_page.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/export_page.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/profile_page.dart';
import 'package:gathering_app/Service/Controller/bottom_nav_controller.dart';
import 'package:provider/provider.dart';

class BottomNavBarScreen extends StatefulWidget {
  final int initialIndex;
  const BottomNavBarScreen({super.key, this.initialIndex = 0});
  static const String name = '/bottom-navbar-screen';

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  final List<Widget> _pages = [
    const LoadCalculatorPage(),
    const RatePlannerPage(),
    const CostsPage(),
    const ExportPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavController>(
      builder: (context, controller, child) {
        return Scaffold(
          extendBody: true,
          body: _pages[controller.selectedIndex],
          bottomNavigationBar: Container(
            height: 80.h,
            decoration: const BoxDecoration(
              color: Color(0xFF010B0B),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.touch_app, 'Load', controller),
                _buildNavItem(1, Icons.track_changes, 'Goals', controller),
                _buildNavItem(2, Icons.account_balance_wallet, 'Costs', controller),
                _buildNavItem(3, Icons.file_download, 'Export', controller),
                _buildNavItem(4, Icons.person, 'Profile', controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, BottomNavController controller) {
    bool isSelected = controller.selectedIndex == index;
    return GestureDetector(
      onTap: () => controller.onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 65.w,
        height: 55.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D193) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 22.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
