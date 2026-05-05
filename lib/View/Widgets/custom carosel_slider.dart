import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CustomCarousel extends StatefulWidget {
  final EventData event;
  const CustomCarousel({super.key, required this.event});

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Fallback if no images provided
    final List<String> displayImages =
        (widget.event.images != null && widget.event.images!.isNotEmpty)
            ? widget.event.images!
            : [];

    if (displayImages.isEmpty) {
      return Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.grey.shade300,
        ),
        child: Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Carousel Slider
        Column(
          children: [
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: displayImages.length,
                  itemBuilder: (context, index, realIndex) {
                    final String imgUrl =
                        "${Urls.baseUrl}${displayImages[index]}";
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 200.h,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    aspectRatio: 16 / 9,
                    autoPlayInterval: Duration(seconds: 4),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeFactor: 0.3,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Consumer<SavedEventController>(
                    builder: (context, controller, _) {
                      final isSaved = controller.isSaved(widget.event);
                      return GestureDetector(
                        onTap: () async {
                          final result =
                              await controller.toggleSave(widget.event);
                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 800),
                                content: Text(
                                  result ? "Event saved" : "Removed from saved",
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8.r),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFFFF006E),
                            size: 24.sp,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: displayImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  bool isActive = _currentIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    height: 8.h,
                    width: isActive ? 20.w : 8.w,
                    // সিলেক্টেড ডট লম্বা
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFB026FF)
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFFB026FF).withOpacity(0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
