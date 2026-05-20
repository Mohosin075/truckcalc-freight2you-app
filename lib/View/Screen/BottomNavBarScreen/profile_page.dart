import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/Service/Controller/auth_controller.dart';
import 'package:truckcalc/Service/Controller/bottom_nav_controller.dart';
import 'package:truckcalc/Service/Controller/calculation_controller.dart';
import 'package:truckcalc/Service/Controller/profile_page_controller.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/CustomButton.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/history_page.dart';
import 'package:truckcalc/View/Screen/BottomNavBarScreen/subscription_page.dart';
import 'package:truckcalc/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:truckcalc/View/Widgets/customSnacBar.dart';
import 'package:provider/provider.dart';
import 'package:truckcalc/Service/urls.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<ProfileController>(context, listen: false);
      if (profile.currentUser != null) {
        _nameController.text = profile.currentUser?.name ?? '';
        _emailController.text = profile.currentUser?.email ?? '';
      }
      Provider.of<CalculationController>(context, listen: false).fetchStats();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, LogInScreen.name, (route) => false);
    }
  }

  Future<void> _handleSave() async {
    final profileController = Provider.of<ProfileController>(context, listen: false);
    bool success = await profileController.updateProfile(
      name: _nameController.text.trim(),
    );

    if (mounted) {
      showCustomSnackBar(
        context: context,
        message: success ? "Profile updated successfully!" : (profileController.errorMessage ?? "Update failed"),
        isError: !success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: _handleLogout,
                      child: Text('Log out', style: TextStyle(color: const Color(0xFFE57373), fontSize: 14.sp, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildUserInfo(),
                SizedBox(height: 24.h),
                _buildEditForm(),
                SizedBox(height: 12.h),
                CustomButton(
                  buttonName: 'View All History',
                  isYellowGradient: true,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
                  },
                ),
                SizedBox(height: 12.h),
                _buildSubscriptionCard(context),
                SizedBox(height: 12.h),
                _buildStatsSection(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Consumer<ProfileController>(
      builder: (context, profile, child) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF7E57C2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundImage: (profile.currentUser?.profile != null && profile.currentUser!.profile!.isNotEmpty)
                        ? NetworkImage(profile.currentUser!.profile!.startsWith('http')
                            ? "${profile.currentUser!.profile!}?t=${profile.profileImageSalt}"
                            : "${Urls.baseUrl.replaceAll('/api/v1', '')}${profile.currentUser!.profile!.startsWith('/') ? '' : '/'}${profile.currentUser!.profile!}?t=${profile.profileImageSalt}")
                        : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => profile.uploadProfileImage(),
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3F51B5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_note, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(profile.currentUser?.name ?? 'Shahriar', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
            Text(profile.currentUser?.id ?? '123456789', style: TextStyle(color: Colors.white60, fontSize: 13.sp)),
          ],
        );
      },
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _buildTextField('Full name', 'Shahriar', _nameController),
          SizedBox(height: 12.h),
          _buildTextField('Email', 'you@email.com', _emailController, readOnly: true),
          SizedBox(height: 20.h),
          Consumer<ProfileController>(
            builder: (context, profile, child) {
              return CustomButton(
                buttonName: 'Save changes',
                isLoading: profile.inProgress,
                onPressed: _handleSave,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Consumer<CalculationController>(
      builder: (context, controller, child) {
        final planName = controller.stats?['planName'] ?? 'No Plan';
        final daysLeft = controller.stats?['planLeftDays'] ?? 0;
        
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subscription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(planName, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: daysLeft < 7 ? const Color(0xFFD32F2F) : const Color(0xFF00D193), 
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text('${daysLeft}d left', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildOutlineButton('View Plans', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                    }),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildOutlineButton('Export Data', () {
                      Provider.of<BottomNavController>(context, listen: false).onItemTapped(3);
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOutlineButton(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<CalculationController>(
      builder: (context, controller, child) {
        final totalCalc = controller.stats?['totalCalculations'] ?? 0;
        final daysLeft = controller.stats?['planLeftDays'] ?? 0;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('$totalCalc', 'Calculations'),
                  _buildStatItem('${daysLeft}d', 'Plan left'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 11.sp)),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style:  TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            fillColor:  const Color(0xFF081414).withOpacity(0.5),
            filled: true,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF00D193))),
          ),
        ),
      ],
    );
  }
}
