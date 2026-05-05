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
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  
  static const String name = '/user-profile';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image(image: AssetImage('assets/images/instagram.png')),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_none)),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<ThemeProvider>(
        builder: (context, controller, child) {
          return Consumer<ProfileController>(
            builder: (context, profileController, child) {
              final user = profileController.currentUser;
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 100.h,
                              width: 100.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Provider.of<ThemeProvider>(
                                      context,
                                    ).isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[200],
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black,
                                ),
                              ),
                              child: Center(
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.camera_alt),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
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
                                  Text(
                                    '${user?.email}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(color: Colors.grey),
                                  ),
                                  // description may be long — limit lines and allow ellipsis
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${user?.description ?? ''}',
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
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
                            Column(
                              children: [
                                Text(
                                  '10',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium!.copyWith(),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  'Events',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color:
                                            Provider.of<ThemeProvider>(
                                              context,
                                            ).isDarkMode
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '432',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  'Followers',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color:
                                            Provider.of<ThemeProvider>(
                                              context,
                                            ).isDarkMode
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '322',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  'Following',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color:
                                            Provider.of<ThemeProvider>(
                                              context,
                                            ).isDarkMode
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                ),
                              ],
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
                                  backgroundColor: Colors.deepPurpleAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ),
                            ),

                            SizedBox(width: 10.w),

                            Expanded(
                              child: SizedBox(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Message',
                                    style: TextStyle(fontSize: 15.sp),
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
                                                overflow: TextOverflow.ellipsis,
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
                      ],
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
}
