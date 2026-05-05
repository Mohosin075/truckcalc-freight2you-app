import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gathering_app/Service/Controller/profile_page_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/details_screen.dart';

import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:gathering_app/View/Widgets/auth_textFormField.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';

import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:gathering_app/Service/Controller/bottom_nav_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedCategoryIndex = 0;
  bool showSettingsCard = false;
  bool switchON = false;
  bool notificationSwitch = false;

  final List<Map<String, dynamic>> categories = [
    {"label": "All", "icon": Icons.auto_awesome},
    {"label": "Nightlife", "icon": Icons.nights_stay_outlined},
    {"label": "Music", "icon": Icons.music_note_outlined},
    {"label": "Concerts", "icon": Icons.mic_none_outlined},
    {"label": "Food & Drinks", "icon": Icons.local_drink_outlined},
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().initialize();
      context.read<ProfileController>().fetchProfile(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emialController.dispose();
    phoneController.dispose();
    locationController.dispose();
    bioController.dispose();
    super.dispose();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emialController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  void _showEditProfileDialog(BuildContext context) {
    final profileController = context.read<ProfileController>();
    final currentUser = profileController.currentUser;

    if (currentUser != null) {
      nameController.text = currentUser.name ?? '';
      emialController.text = currentUser.email ?? '';
      // phoneController.text = currentUser. ?? ''; // model-এ phone থাকলে
      locationController.text = currentUser.location?.type ?? '';
      bioController.text = currentUser.description ?? '';
    }

    bool isLoading = false; // Save button-এ loading দেখানোর জন্য

    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (_) => Consumer<ThemeProvider>(
        builder: (context, ctrl, child) => StatefulBuilder(
          builder: (context, setState) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Update your personal information",
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Container(
                              height: 36.r,
                              width: 36.r,
                              decoration: BoxDecoration(
                                color: ctrl.isDarkMode
                                    ? const Color(0xFF3E043F)
                                    : const Color(0xFF686868),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.all(10.r),
                              child: Image.asset(
                                'assets/images/cross_icon.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Form Fields
                      Column(
                        children: [
                          AuthTextField(
                            hintText: 'user name',
                            labelText: 'Name',
                            controller: nameController,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            hintText: 'your email',
                            labelText: 'Email',
                            controller: emialController,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            hintText: '+43 04324',
                            labelText: 'Phone',
                            controller: phoneController,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            hintText: 'Change Location',
                            labelText: 'Location',
                            controller: locationController,
                          ),
                          SizedBox(height: 16.h),
                          AuthTextField(
                            hintText: 'Tell about yourself',
                            labelText: 'Your bio',
                            controller: bioController,
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: ctrl.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                elevation: 0,
                                side: BorderSide(
                                  color: ctrl.isDarkMode
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      bool success = await profileController
                                          .updateProfile(
                                            // forceRefresh: true,
                                            name: nameController.text.trim(),
                                            description: bioController.text
                                                .trim(),

                                            // location: locationController.text.trim(),
                                          );

                                      if (success) {
                                        setState(() {
                                          isLoading = false;
                                        });

                                        if (mounted) {
                                          // if success user profile update go to show snback bar
                                          showCustomSnackBar(
                                            context: context,
                                            message:
                                                "Profile updated successfully! 🎉",
                                          );

                                          // again profile refresh
                                          Provider.of<ProfileController>(
                                            context,
                                            listen: false,
                                          ).fetchProfile(forceRefresh: true);

                                          //  Dialog off
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (mounted) {
                                          showCustomSnackBar(
                                            context: context,
                                            message:
                                                profileController
                                                    .errorMessage ??
                                                "Failed to update profile",
                                            isError: true,
                                          );
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Save Change',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveProfileChanges() async {
    final controller = context.read<ProfileController>();
    bool isSuccess = await controller.updateProfile(
      name: nameController.text.trim(),
      description: bioController.text.trim(),
      // location: locationController.text.trim(),
    );
    if (isSuccess) {
      showCustomSnackBar(
        context: context,
        message: "Profile updated successfully! 🎉",
      );
      Navigator.pop(context);
    } else {
      showCustomSnackBar(
        context: context,
        message: controller.errorMessage ?? "Failed to update profile",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   surfaceTintColor: Colors.transparent,
      //   ///ekhon comment thak pore dekha jabe
      //   // actions: [
      //   //   Consumer<NotificationController>(
      //   //     builder: (context, notificationController, child) => Stack(
      //   //       clipBehavior: Clip.none,
      //   //       children: [
      //   //         IconButton(
      //   //           onPressed: () {
      //   //             Navigator.pushNamed(context, NotificationScreen.name);
      //   //           },
      //   //           icon: const Icon(Icons.notifications_none),
      //   //         ),
      //   //         if (notificationController.unreadCount > 0)
      //   //           Positioned(
      //   //             right: 4,
      //   //             top: 4,
      //   //             child: CircleAvatar(
      //   //               radius: 9,
      //   //               backgroundColor: const Color(0xFFFF006E),
      //   //               child: Text(
      //   //                 '${notificationController.unreadCount}',
      //   //                 style: const TextStyle(
      //   //                   color: Colors.white,
      //   //                   fontSize: 10,
      //   //                 ),
      //   //               ),
      //   //             ),
      //   //           ),
      //   //       ],
      //   //     ),
      //   //   ),
      //   // ],
      // ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<ProfileController>(
            builder: (context, profileController, child) {
              final user = profileController.currentUser;

              // Debug: Print user stats
              if (kDebugMode) {
                debugPrint('🔍 Profile Page - User: ${user?.name}');
                debugPrint('🔍 Profile Page - Events: ${user?.stats?.events}');
                debugPrint('🔍 Profile Page - Followers: ${user?.stats?.followers}');
                debugPrint('🔍 Profile Page - Following: ${user?.stats?.following}');
              }

              return SafeArea(
                child: RefreshIndicator(
                  onRefresh: () =>
                      profileController.fetchProfile(forceRefresh: true),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(3.w),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.deepPurpleAccent,
                                          Colors.purpleAccent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Container(
                                      height: 100.h,
                                      width: 100.h,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Provider.of<ThemeProvider>(
                                              context,
                                            ).isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.white,
                                      ),
                                      child:
                                          user?.profile != null &&
                                              user!.profile!.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: Uri.encodeFull(
                                                user.profile!.startsWith('http')
                                                    ? user.profile!
                                                    : '${Urls.baseUrl}${user.profile!.startsWith('/') ? '' : '/'}${user.profile}',
                                              ),
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                    Icons.person,
                                                    size: 50.sp,
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 50.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final success = await profileController
                                            .uploadProfileImage();
                                        if (success && context.mounted) {
                                          showCustomSnackBar(
                                            context: context,
                                            message:
                                                'Profile image updated successfully',
                                            isError: false,
                                          );
                                        } else if (profileController
                                                    .errorMessage !=
                                                null &&
                                            context.mounted) {
                                          showCustomSnackBar(
                                            context: context,
                                            message:
                                                profileController.errorMessage!,
                                            isError: true,
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 35.r,
                                        width: 35.r,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 18.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (profileController.inProgress)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black26,
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: 15.w),
                              // make the right column flexible so long text wraps instead of overflowing
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user?.name}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge!.copyWith(),
                                    ),
                                    // email should be a single line with ellipsis
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${user?.description ?? ''}',
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.w200,
                                          ),
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
                              _buildStatColumn(
                                context,
                                '${user?.stats?.events ?? 0}',
                                'Events',
                              ),
                              _buildStatColumn(
                                context,
                                '${user?.stats?.followers ?? 0}',
                                'Followers',
                              ),
                              _buildStatColumn(
                                context,
                                '${user?.stats?.following ?? 0}',
                                'Following',
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 48),
                                    backgroundColor: const Color(0xFF0D0D15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  onPressed: () =>
                                      _showEditProfileDialog(context),
                                  child: Text(
                                    'Edit Profile',
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
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                    backgroundColor: const Color(0xFF0D0D15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      SettingsScreen.name,
                                    );
                                  },
                                  child: Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          ///favorite spots
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'FAVORITE SPOTS',
                              style: Theme.of(context).textTheme.titleSmall!
                                  .copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          SizedBox(height: 15.h),

                          // Favorite Spots List
                          SizedBox(
                            height: 230.h,
                            child: Consumer<SavedEventController>(
                              builder: (context, savedController, child) {
                                final savedEvents = savedController.savedEvents;

                                if (savedController.inProgress) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (savedEvents.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No saved yet 💾',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: savedEvents.length,
                                  itemBuilder: (context, index) {
                                    final event = savedEvents[index];

                                    return Padding(
                                      padding: EdgeInsets.only(right: 12.w),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            DetailsScreen.name,
                                            arguments: event.event.id,
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 180.h,
                                              width: 180.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                image: DecorationImage(
                                                  image:
                                                      (event.event.images !=
                                                              null &&
                                                          event
                                                              .event
                                                              .images!
                                                              .isNotEmpty)
                                                      ? NetworkImage(
                                                          "${Urls.baseUrl}${event.event.images!.first}",
                                                        )
                                                      : const AssetImage(
                                                              'assets/images/container_img.png',
                                                            )
                                                            as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),

                                              /// 🔖 UNSAVE BUTTON
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.w),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.bookmark,
                                                      color: const Color(
                                                        0xFFFF006E,
                                                      ),
                                                      size: 28.sp,
                                                    ),
                                                    onPressed: () async {
                                                      final result =
                                                          await savedController
                                                              .toggleSave(
                                                                event.event,
                                                              );

                                                      if (result == false) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Removed from saved',
                                                            ),
                                                            duration: Duration(
                                                              milliseconds: 800,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Expanded(
                                              child: SizedBox(
                                                width: 180.w,
                                                child: Text(
                                                  event.event.title ??
                                                      'Untitled Event',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,

                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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

                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Interests',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          // color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),

                                SizedBox(height: 20.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 60.h,
                                            width: 60.h,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(
                                                0xFFCC18CA,
                                              ).withOpacity(0.15),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Image.asset(
                                                  height: 20,
                                                  width: 20,
                                                  'assets/images/calender_icon.png',
                                                  color: Color(0xFFB026FF),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${user?.stats?.events ?? 0}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 25.sp),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'Events Attended',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  fontSize: 12.sp.clamp(12, 12),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 60.h,
                                            width: 60.h,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(
                                                0xFFCC18CA,
                                              ).withOpacity(0.15),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Image.asset(
                                                  height: 20,
                                                  width: 20,
                                                  'assets/images/review_icon.png',
                                                  color: Color(0xFFB026FF),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${user?.stats?.followers ?? 0}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(fontSize: 25.sp),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'Reviews',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                  fontSize: 12.sp.clamp(12, 12),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          context
                                              .read<BottomNavController>()
                                              .onItemTapped(2);
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 60.h,
                                              width: 60.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(
                                                  0xFFCC18CA,
                                                ).withOpacity(0.15),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Image.asset(
                                                    height: 20,
                                                    width: 20,
                                                    'assets/images/fav_icon.png',
                                                    color: Color(0xFFB026FF),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              '${user?.stats?.following ?? 0}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(fontSize: 25.sp),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              'Favorites',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                    fontSize: 12.sp.clamp(
                                                      12,
                                                      12,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB026FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(count, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 5.h),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.grey
                : Colors.black,
          ),
        ),
      ],
    );
  }
}
