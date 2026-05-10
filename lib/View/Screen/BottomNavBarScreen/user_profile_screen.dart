import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String name = '/user-profile';
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().fetchProfile(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ),
      body: AppBackground(
        child: Consumer<ProfileController>(
          builder: (context, controller, child) {
            final user = controller.currentUser;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  CircleAvatar(radius: 50.r, backgroundColor: Colors.white10, child: const Icon(Icons.person, color: Colors.white24, size: 50)),
                  SizedBox(height: 16.h),
                  Text(user?.name ?? 'Loading...', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '', style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
                  SizedBox(height: 30.h),
                  _buildProfileMenu('Edit Profile', Icons.edit),
                  _buildProfileMenu('Notification Settings', Icons.notifications_active),
                  _buildProfileMenu('Help & Support', Icons.help_outline),
                  _buildProfileMenu('Logout', Icons.logout, isDestructive: true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileMenu(String title, IconData icon, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : const Color(0xFF00D193)),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 15.sp)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () {},
      ),
    );
  }
}
