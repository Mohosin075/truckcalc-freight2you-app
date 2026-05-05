import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_review_model_by_event_id.dart';
import 'package:gathering_app/Service/Controller/reivew_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
import 'package:provider/provider.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/other_user_profile_screen.dart';
import 'package:intl/intl.dart';

class AllReviewsScreen extends StatelessWidget {
  final String eventId;

  const AllReviewsScreen({super.key, required this.eventId});

  static const String name = '/all-reviews-screen';

  String _formatReviewTime(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, size: 20.sp),
          ),
        ),
      ),
      body: Consumer<ReivewController>(
        builder: (context, reviewCtrl, child) {
          if (reviewCtrl.inProgress) {
            return Center(child: CircularProgressIndicator());
          }
          if (reviewCtrl.review.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    "No reviews yet.",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Calculate average rating (mock logic if not provided by controller)
          double avgRating = 0;
          if (reviewCtrl.review.isNotEmpty) {
            avgRating =
                reviewCtrl.review.map((e) => e.rating).reduce((a, b) => a + b) /
                reviewCtrl.review.length;
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: reviewCtrl.review.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(
                  context,
                  avgRating,
                  reviewCtrl.totalReview,
                  reviewCtrl.review,
                );
              }
              return _buildVerticalReviewCard(
                context,
                reviewCtrl.review[index - 1],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double avgRating,
    int totalReviews,
    List<AllReviewModelByEventId> reviews,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate rating distribution
    Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      int rating = r.rating.round();
      if (starCounts.containsKey(rating)) {
        starCounts[rating] = starCounts[rating]! + 1;
      }
    }

    return Container(
      padding: EdgeInsets.all(24.r),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avgRating == 0.0 ? "0.0" : avgRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < avgRating.floor()
                        ? Icons.star
                        : (index < avgRating
                              ? Icons.star_half
                              : Icons.star_border),
                    color: Colors.amber,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "$totalReviews Reviews",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Spacer(),
          // Visual bars for ratings based on actual data
          Column(
            children: List.generate(5, (index) {
              int starLevel = 5 - index;
              int count = starCounts[starLevel] ?? 0;
              double factor = totalReviews > 0 ? count / totalReviews : 0.0;

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Text(
                      starLevel.toString(),
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 100.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: factor > 0
                          ? FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: factor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalReviewCard(
    BuildContext context,
    AllReviewModelByEventId review,
  ) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            if (review.reviewerId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OtherUserProfileScreen(userId: review.reviewerId),
                ),
              );
            } else {
              showCustomSnackBar(
                context: context,
                message: "User profile not found.",
                isError: true,
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB026FF).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        backgroundImage: review.reviewerImage.isNotEmpty
                            ? NetworkImage(
                                review.reviewerImage.startsWith('http')
                                    ? review.reviewerImage
                                    : "${Urls.baseUrl}${review.reviewerImage}",
                              )
                            : null,
                        child: review.reviewerImage.isEmpty
                            ? Icon(
                                Icons.person,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 10.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _formatReviewTime(review.createdAt),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  review.review,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Helpful",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                      size: 14.sp,
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.share_outlined, color: Colors.grey, size: 14.sp),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
