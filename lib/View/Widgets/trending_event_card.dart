import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TrendingEventCard extends StatelessWidget {
  final EventData event;
  final VoidCallback onTap;

  const TrendingEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // -- Data Parsing --
    final String imageUrl = (event.images != null && event.images!.isNotEmpty)
        ? "${Urls.baseUrl}${event.images!.first}"
        : "assets/images/personLocation.jpg";

    final String category = event.category ?? 'Event';
    final String title = event.title ?? "Untitled Event";
    // Date formatting (basic) - You might want intl package for "Nov 15 • 8:00 PM"
    final String dateStr = event.startDate != null
        ? "${event.startDate!.day}/${event.startDate!.month} • ${event.startTime ?? ''}"
        : "Date TBA";
    final String location = event.address ?? "Location TBA";
    final double rating = 4.8; // Static for now as requested/design

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isDark ? const Color(0xFFCC18CA) : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Section (Stack) ---
            Expanded(
              flex: 3, // ~60% height for image
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // 2. Category Chip (Top Left)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFB026FF,
                        ).withOpacity(0.9), // Purple accent
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // 3. Bookmark Button (Top Right)
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Consumer<SavedEventController>(
                      builder: (context, controller, _) {
                        final isSaved = controller.isSaved(event);
                        return GestureDetector(
                          onTap: () async {
                            await controller.toggleSave(event);
                          },
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: const Color(0xFFFF006E),
                              size: 18.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- Details Section ---
            Expanded(
              flex: 2, // ~40% text
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            dateStr,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Location + Rating
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // Rating (Next to location as requested)
                        Container(
                          margin: EdgeInsets.only(left: 4.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12.sp,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "$rating",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
