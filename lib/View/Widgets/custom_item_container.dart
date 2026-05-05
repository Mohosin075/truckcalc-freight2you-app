import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Custom_item_container extends StatelessWidget {
  final EventData event;
  final VoidCallback? onTap; // <-- নতুন parameter

  const Custom_item_container({
    super.key,
    required this.event,
    this.onTap, // optional
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedEventController>(
      builder: (context, controller, child) {
        final bool isCurrentlySaved = controller.isSaved(event);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                width: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFCC18CA).withOpacity(0.15)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                        child: CachedNetworkImage(
                          imageUrl:
                              (event.images != null && event.images!.isNotEmpty)
                              ? "${Urls.baseUrl}${event.images!.first}"
                              : "assets/images/personLocation.jpg",
                          height: 150.h,
                          width: double.infinity,
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

                      // Category Chip (Top Left)
                      Positioned(
                        left: 8.w,
                        top: 8.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB026FF), // Purple
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            event.category ?? "Event",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Bookmark Button (Top Right)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Selector<SavedEventController, bool>(
                          selector: (_, c) => c.isSaved(event),
                          builder: (context, isSaved, _) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(
                                  0.3,
                                ), // Background for better visibility
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border_outlined,
                                  color: const Color(0xFFFF006E),
                                ),
                                onPressed: () async {
                                  final result = await context
                                      .read<SavedEventController>()
                                      .toggleSave(event);

                                  if (result != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        content: Text(
                                          result
                                              ? "Event saved"
                                              : "Removed from saved",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // বাকি title, date, location...
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(6.w), // Slightly less padding
                    child: SingleChildScrollView(
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent manual scroll but allow content to fit or clip
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title ?? "Untitled Event",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp, // Slightly smaller font
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h), // Less spacing
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/calender_icon.png',
                                height: 14.h,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  "${event.startDate ?? "00"}",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h), // Less spacing
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  event.description?.isNotEmpty == true
                                      ? event.description!
                                      : "No description available",
                                  softWrap: true,
                                  maxLines: 2, // Limit to 2 lines
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
