import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:gathering_app/View/Screen/authentication_screen/log_in_screen.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String name = '/settings-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Settings Group
                _buildSectionCard(
                  context,
                  title: "App Settings",
                  children: [
                    Consumer<ProfileController>(
                      builder: (context, profileController, child) {
                        final settings = profileController.currentUser?.settings;
                        if (settings == null) return const SizedBox();

                        return Column(
                          children: [
                            _buildSwitchTile(
                              context,
                              title: "Push Notification",
                              subtitle: "Get notified about events",
                              value: settings.pushNotification,
                              onChanged: (val) => profileController
                                  .updateSettingsLocally(pushNotification: val),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              context,
                              title: "Email Notifications",
                              subtitle: "Receive event updates via email",
                              value: settings.emailNotification,
                              onChanged: (val) => profileController
                                  .updateSettingsLocally(emailNotification: val),
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              context,
                              title: "Location Services",
                              subtitle: "Find events near you",
                              value: settings.locationService,
                              onChanged: (val) => profileController
                                  .updateSettingsLocally(locationService: val),
                            ),
                            _buildDivider(),
                            _buildDropdownTile(
                              context,
                              title: "Profile Status",
                              subtitle: "Public or Private profile",
                              value: settings.profileStatus,
                              items: ["public", "private"],
                              onChanged: (val) {
                                if (val != null)
                                  profileController.updateSettingsLocally(
                                    profileStatus: val,
                                  );
                              },
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              context,
                              title: "Dark Mode",
                              subtitle:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                  ? 'Currently Dark'
                                  : 'Currently Light',
                              value: Provider.of<ThemeProvider>(
                                context,
                              ).isDarkMode,
                              onChanged: (val) => Provider.of<ThemeProvider>(
                                context,
                                listen: false,
                              ).toggleTheme(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Quick Actions Group
                _buildSectionCard(
                  context,
                  title: "Quick Actions",
                  children: [
                    _buildActionTile(
                      context,
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      onTap: () {
                        // TODO: Implement Change Password
                      },
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      context,
                      icon: Icons.bookmark_border,
                      title: "Saved Events",
                      onTap: () {
                        Navigator.pushNamed(context, '/saved-events');
                      },
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      context,
                      icon: Icons.logout,
                      title: "Sign Out",
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () async {
                        final authController = context.read<AuthController>();
                        await authController.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => LogInScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF00D193).withOpacity(0.15)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00D193),
              ),
            ),
            SizedBox(height: 20.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.sp, color: Colors.white60),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            activeColor: const Color(0xFF00D193),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.sp, color: Colors.white60),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF010B0B),
          style: const TextStyle(color: Colors.white),
          underline: const SizedBox(),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.substring(0, 1).toUpperCase() + e.substring(1)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFF00D193),
        size: 22.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Colors.white,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 18.sp, color: Colors.white60),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 20.h,
      color: Colors.white.withOpacity(0.1),
    );
  }
}
