import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/other_user_profile_controller.dart';
import 'package:gathering_app/Model/ChatModel.dart';
import 'package:gathering_app/Service/Controller/chat_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/user_chat_screen.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
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
      context.read<OtherUserProfileController>().fetchUserProfile(
        widget.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: Consumer<ThemeProvider>(
          builder: (context, controller, child) => Center(
            child: GestureDetector(
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
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<OtherUserProfileController>(
        builder: (context, controller, child) {
          if (controller.inProgress && controller.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.userProfile == null) {
            return Center(
              child: Text(controller.errorMessage!),
            );
          }

          final user = controller.userProfile;
          if (user == null) {
            return const Center(child: Text("User not found"));
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            height: 100.h,
                            width: 100.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Provider.of<ThemeProvider>(context).isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.white,
                            ),
                            child: ClipOval(
                              child: user.profile != null && user.profile!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: Uri.encodeFull(user.profile!.startsWith('http')
                                          ? user.profile!
                                          : '${Urls.baseUrl}${user.profile!.startsWith('/') ? '' : '/'}${user.profile}'),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) => Icon(
                                        Icons.person,
                                        size: 50.sp,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : Icon(Icons.person, size: 50.sp, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? 'Unknown',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                user.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Colors.grey),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                user.description ?? '',
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(fontWeight: FontWeight.w200),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(context, '${user.stats?.events ?? 0}', 'Events'),
                        _buildStatColumn(context, '${user.stats?.followers ?? 0}', 'Followers'),
                        _buildStatColumn(context, '${user.stats?.following ?? 0}', 'Following'),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 45.h),
                              backgroundColor: (user.isFollowing ?? false) 
                                  ? Colors.grey[800] 
                                  : const Color(0xFF0D011D), // Dark purple/black
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(
                                  color: (user.isFollowing ?? false) 
                                      ? Colors.transparent 
                                      : Colors.white10,
                                ),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              if (user.isFollowing ?? false) {
                                _showUnfollowDialog(context, controller, user.name ?? 'User');
                              } else {
                                final success = await controller.toggleFollow(widget.userId);
                                if (success && context.mounted) {
                                  showCustomSnackBar(
                                    context: context,
                                    message: "You are now following ${user.name}",
                                  );
                                } else if (!success && context.mounted) {
                                  showCustomSnackBar(
                                    context: context,
                                    message: controller.errorMessage ?? "Failed to follow",
                                    isError: true,
                                  );
                                  controller.clearError();
                                }
                              }
                            },
                            child: controller.followInProgress 
                                ? SizedBox(
                                    height: 18.h,
                                    width: 18.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    (user.isFollowing ?? false) ? 'Following' : 'Follow',
                                    style: TextStyle(
                                      fontSize: 15.sp, 
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Consumer<ChatController>(
                            builder: (context, chatController, child) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 45.h),
                                  backgroundColor: const Color(0xFF0D011D), // Same dark color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: const BorderSide(
                                      color: Colors.white10,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  final chatId = await chatController
                                      .createChat(widget.userId);

                                  if (chatId != null) {
                                    final user = controller.userProfile;
                                    final chat = ChatModel(
                                      id: chatId,
                                      otherUserId: widget.userId,
                                      name: user?.name,
                                      imageIcon: user?.profile,
                                      status: 'offline',
                                    );

                                    context.read<BottomNavController>().onItemTapped(3);
                                    Navigator.of(context).popUntil((route) => route.isFirst); 

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            UserChatScreen(chat: chat),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          chatController.errorMessage ??
                                              "Failed to create chat",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: chatController.inProgress
                                    ? SizedBox(
                                        height: 18.h,
                                        width: 18.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Message',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),

                  ],
                ),
                    SizedBox(height: 20.h),
                    
                    /// Favorite Spots Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FAVORITE SPOTS',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    
                    // Note: Favorite lists are usually private or separate API. 
                    // Showing a placeholder for now as requested to keep structure.
                    SizedBox(
                      height: 50.h,
                      child: Center(
                        child: Text(
                          'No public favorites to show',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  void _showUnfollowDialog(BuildContext context, OtherUserProfileController controller, String name) {
    final user = controller.userProfile;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: Theme.of(context).cardColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Avatar Container
                Container(
                  width: 90.w,
                  height: 90.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: user?.profile != null && user!.profile!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: Uri.encodeFull(user.profile!.startsWith('http')
                                  ? user.profile!
                                  : '${Urls.baseUrl}${user.profile!.startsWith('/') ? '' : '/'}${user.profile}'),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 45.sp,
                                color: Colors.grey[400],
                              ),
                            )
                          : Icon(Icons.person, size: 45.sp, color: Colors.grey[400]),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Stop following $name?",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  "If you change your mind, you'll have to request to follow $name again.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                // Divider
                Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                SizedBox(height: 12.h),
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final success = await controller.toggleFollow(widget.userId);
                      if (success && context.mounted) {
                        showCustomSnackBar(
                          context: context,
                          message: "Unfollowed ${user?.name ?? 'user'}",
                        );
                      } else if (!success && context.mounted) {
                         showCustomSnackBar(
                          context: context,
                          message: controller.errorMessage ?? "Failed to unfollow",
                          isError: true,
                        );
                        controller.clearError();
                      }
                    },
                    child: const Text(
                      "Unfollow",
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

