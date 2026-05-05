// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/Controller/getAllEvent_controller.dart';
import 'package:gathering_app/Service/Controller/notification_controller.dart';
import 'package:gathering_app/Service/Controller/user_event_controller.dart';
import 'package:gathering_app/Service/urls.dart';

import 'package:gathering_app/View/Screen/BottomNavBarScreen/details_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/notification_screen.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:gathering_app/View/Widgets/serch_textfield.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:gathering_app/View/Widgets/custom_item_container.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String appBarTitle = 'Discover';
  final String appBarSubTitle = 'Find your next adventure';
  final String trendName = 'Trending Now';
  // late final EventData event;
  TextEditingController searchController = TextEditingController();
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetAllEventController>(context, listen: false).getAllEvents();
      context.read<SavedEventController>().loadMySavedEvents();
      Provider.of<NotificationController>(
        context,
        listen: false,
      ).fetchNotifications();
      Provider.of<UserEventController>(
        context,
        listen: false,
      ).fetchUserEvents();
    });
  }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  Future<void> _onRefresh() async {
    final success = await Provider.of<GetAllEventController>(
      context,
      listen: false,
    ).getAllEvents();
    final userEventsSuccess = await Provider.of<UserEventController>(
      context,
      listen: false,
    ).fetchUserEvents();
    if (success && userEventsSuccess) {
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: Consumer<ThemeProvider>(
                    builder: (context, controller, child) => Text(
                      'Gathering',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 27.sp,
                        color: controller.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Consumer<NotificationController>(
                      builder: (context, notificationController, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  NotificationScreen.name,
                                );
                              },
                              icon: const Icon(Icons.notifications_none),
                            ),
                            if (notificationController.unreadCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: CircleAvatar(
                                  radius: 9,
                                  backgroundColor: const Color(0xFFFF006E),
                                  child: Text(
                                    '${notificationController.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Expanded(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: _onRefresh,
                header: CustomHeader(
                  builder: (context, mode) {
                    Widget body;
                    if (mode == RefreshStatus.idle) {
                      body = Text("Pull down to refresh");
                    } else if (mode == RefreshStatus.refreshing) {
                      body = CircularProgressIndicator(
                        color: Color(0xFFB026FF),
                      );
                    } else if (mode == RefreshStatus.completed) {
                      body = Icon(Icons.done, color: Colors.green);
                    } else if (mode == RefreshStatus.failed) {
                      body = Icon(Icons.error, color: Colors.red);
                    } else {
                      body = Text("Release to refresh");
                    }
                    return SizedBox(height: 60.0, child: Center(child: body));
                  },
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appBarTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  appBarSubTitle,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Colors.grey,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SearchTextField(
                          controller: searchController,
                          onChanged: (query) {
                            context.read<GetAllEventController>().updateSearchQuery(query);
                            context.read<UserEventController>().updateSearchQuery(query);
                          },
                          hintText: 'Search events, venues',
                        ),

                        Consumer<GetAllEventController>(
                          builder: (context, controller, _) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: controller.categories.map((cat) {
                                    bool isSelected =
                                        controller.selectedCategory == cat;
                                    return Padding(
                                      padding: EdgeInsets.only(left: 16.0.w),
                                      child: _buildCustomFilterChip(
                                        label: cat,
                                        icon: Icons.category,
                                        isSelected: isSelected,
                                        onTap: () {
                                          controller.applyCategoryFilter(cat);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 10.h),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Consumer<GetAllEventController>(
                            builder: (context, controller, child) {
                              if (controller.inProgress &&
                                  controller.events.isEmpty) {
                                return _buildFeaturedShimmer();
                              }
                              if (controller.events.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ListView.builder(
                                itemCount: controller.topEvent.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final listEvent = controller.topEvent[index];
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          DetailsScreen.name,
                                          arguments: listEvent.id,
                                        ),
                                        child: _buildFeaturedEvent(
                                          listEvent.title ?? " ",
                                          listEvent.description ?? " ",
                                          listEvent.tags,
                                          listEvent.images,
                                          listEvent,
                                        ),
                                      ),
                                      SizedBox(height: 15.h),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // New Horizontal Scroll Section
                        Consumer<GetAllEventController>(
                          builder: (context, controller, _) {
                            if (controller.horizontalEvents.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                SizedBox(height: 10.h),
                                SizedBox(
                                  height: 180.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        controller.horizontalEvents.length,
                                    padding: EdgeInsets.only(left: 16.w),
                                    itemBuilder: (context, index) {
                                      final event =
                                          controller.horizontalEvents[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 12.w),
                                        child: _buildHorizontalEventCard(event),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            );
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              trendName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        Consumer<GetAllEventController>(
                          builder: (context, controller, _) {
                            if (controller.inProgress &&
                                controller.events.isEmpty) {
                              return _buildTrendingShimmer();
                            }
                            if (controller.events.isEmpty) {
                              return _buildEmptyState();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.remainingEvents.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16.w,
                                      crossAxisSpacing: 16.w,
                                      childAspectRatio: 0.80,
                                    ),
                                itemBuilder: (context, index) {
                                  final gridEvent =
                                      controller.remainingEvents[index];

                                  return Custom_item_container(
                                    event: gridEvent,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      DetailsScreen.name,
                                      arguments: gridEvent.id,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // --- Happening Tonight Section ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "🔥 Happening Tonight",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Consumer<UserEventController>(
                          builder: (context, controller, _) {
                            if (controller.inProgress) {
                              return SizedBox(
                                height: 180.h,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (controller.userEvents.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return SizedBox(
                              height: 180.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.userEvents.length,
                                padding: EdgeInsets.only(left: 16.w),
                                itemBuilder: (context, index) {
                                  final event = controller.userEvents[index];
                                  return Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: _buildHorizontalEventCard(event),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // এখানে SmartRefresher শেষ
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedEvent(
    String title,
    String subtitle,
    List<String>? tags,
    List<String>? imgURL,
    EventData event,
  ) {
    final String imageUrl = (event.images != null && event.images!.isNotEmpty)
        ? "${Urls.baseUrl}${event.images!.first}"
        : "assets/images/personLocation.jpg";

    return Consumer<ThemeProvider>(
      builder: (context, controller, child) => Container(
        height: 197.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: controller.isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFCC18CA).withOpacity(0.2),
            width: 1.w,
          ),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Category Chip (Top Left)
            Positioned(
              left: 16.w,
              top: 16.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFB026FF), // Purple
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  event.category ?? "Event",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16.h,
              right: 16.w,
              child: Consumer<SavedEventController>(
                builder: (context, provider, child) {
                  final isSaved = provider.isSaved(
                    event,
                  ); // check from controller
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await provider.toggleSave(event);
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved
                            ? const Color(0xFFFF006E)
                            : (controller.isDarkMode
                                  ? Colors.white
                                  : Color(0xFFFF006E)),
                        size: 25.sp.clamp(25, 26),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.sp.clamp(22, 22),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp.clamp(12, 16),
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
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp.clamp(13, 13),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCustomFilterChip({
    required String label,
    required IconData? icon,
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
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ✨ Loading & Empty States
  // =========================

  Widget _buildFeaturedShimmer() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 15.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 197.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.w,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.80,
        ),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalEventCard(EventData event) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, DetailsScreen.name, arguments: event.id),
      child: Container(
        width: 280.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: DecorationImage(
            image: NetworkImage(
              (event.images != null && event.images!.isNotEmpty)
                  ? '${Urls.baseUrl}${event.images![0]}'
                  : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=500&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Category Chip (top right)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFB026FF).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.white, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      event.category ?? "Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Info
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title ?? "Event Title",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Tonight - ${event.category ?? 'Event'} - ${event.address ?? 'Location TBA'}",
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Stats Row
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.white60,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${event.views ?? 0}",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.group,
                        color: const Color(0xFFFF9E01),
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "${event.favorites ?? 0}+",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11.sp,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🎫", style: TextStyle(fontSize: 60.sp)),
            SizedBox(height: 16.h),
            Text(
              "No events available right now",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Check back later for more adventures!",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
