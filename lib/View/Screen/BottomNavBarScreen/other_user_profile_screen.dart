import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/other_user_profile_controller.dart';
import 'package:gathering_app/Model/ChatModel.dart';
import 'package:gathering_app/Service/Controller/chat_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/user_chat_screen.dart';
import 'package:gathering_app/View/Widgets/app_background.dart';
import 'package:provider/provider.dart';
import 'package:gathering_app/Service/Controller/bottom_nav_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
import 'package:gathering_app/Service/urls.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;
  const OtherUserProfileScreen({super.key, required this.userId});
  static const String name = '/other-user-profile';
  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OtherUserProfileController>().fetchUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30)),
      ),
      body: AppBackground(
        child: Consumer<OtherUserProfileController>(
          builder: (context, controller, child) {
            if (controller.inProgress && controller.userProfile == null) return const Center(child: CircularProgressIndicator(color: Color(0xFF00D193)));
            final user = controller.userProfile;
            if (user == null) return const Center(child: Text("User not found", style: TextStyle(color: Colors.white)));
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.white10,
                      backgroundImage: user.profile != null ? NetworkImage('${Urls.baseUrl}/${user.profile}') : null,
                      child: user.profile == null ? Icon(Icons.person, size: 50.r, color: Colors.white24) : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(user.name ?? 'Unknown', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                    Text(user.email ?? '', style: TextStyle(color: Colors.white60, fontSize: 14.sp)),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('${user.stats?.events ?? 0}', 'Events'),
                        _buildStat('${user.stats?.followers ?? 0}', 'Followers'),
                        _buildStat('${user.stats?.following ?? 0}', 'Following'),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Expanded(child: _buildButton(user.isFollowing == true ? 'Following' : 'Follow', () => controller.toggleFollow(widget.userId), isPrimary: true)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildButton('Message', () async {
                          final chatId = await context.read<ChatController>().createChat(widget.userId);
                          if (chatId != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => UserChatScreen(chat: ChatModel(id: chatId, name: user.name, imageIcon: user.profile))));
                          }
                        })),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Column(children: [Text(val, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white38))]);
  }

  Widget _buildButton(String text, VoidCallback onTap, {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF00D193) : Colors.white10,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
      ),
    );
  }
}
