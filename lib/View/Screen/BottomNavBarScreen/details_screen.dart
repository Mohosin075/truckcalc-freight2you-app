import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_review_model_by_event_id.dart';
import 'package:gathering_app/Model/get_single_event_model.dart';
import 'package:gathering_app/Model/live_chat_message_model.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/all_reviews_screen.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/other_user_profile_screen.dart';
import 'package:gathering_app/Service/Controller/event_details_controller.dart';
import 'package:gathering_app/Service/Controller/reivew_controller.dart';
import 'package:gathering_app/Service/Controller/live_chat_controller.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/Widgets/customSnacBar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:gathering_app/Service/Controller/map_controller.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gathering_app/Model/get_all_event_model.dart'; // Needed for EventData
import 'package:gathering_app/Service/Controller/auth_controller.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  static const String name = '/details-screen';

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  SingleEventDataModel? singleEvent;
  late String eventId;
  GoogleMapController? _mapController;
  bool _isCheckedIn = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String) {
        eventId = arguments;
      } else if (arguments is Map<String, dynamic>) {
        eventId = arguments['id'];
      }

      context.read<EventDetailsController>().getSingleEvent(eventId);
      context.read<ReivewController>().getAllReviewsByEventId(eventId: eventId);
      // Chat messages are fetched only when checking in
      if (_isCheckedIn) {
        context.read<LiveChatController>().fetchMessages(eventId);
      }
    });
  }

  Future<void> _openInMaps() async {
    if (singleEvent?.data?.location?.coordinates == null ||
        singleEvent!.data!.location!.coordinates!.length < 2)
      return;

    final lat = singleEvent!.data!.location!.coordinates![1];
    final lng = singleEvent!.data!.location!.coordinates![0];

    // Using the global map controller to trigger in-app route
    final mapCtrl = context.read<MapController>();
    if (_mapController != null) {
      mapCtrl.setMapController(_mapController!);
    }
    mapCtrl.showRouteToEvent(LatLng(lat, lng));
  }

  Future<void> _shareEventImage() async {
    if (singleEvent?.data == null) return;

    try {
      // Show a toast or snackbar to indicate loading
      showCustomSnackBar(
        context: context,
        message: "Generating shareable image...",
        duration: const Duration(seconds: 1),
      );

      final Uint8List image = await _screenshotController.captureFromWidget(
        Material(
          child: MediaQuery(
            data: MediaQuery.of(context),
            child: _buildShareCard(singleEvent!.data!),
          ),
        ),
        delay: const Duration(milliseconds: 500), // Increased delay for images
        context: context,
      );

      final directory = await getTemporaryDirectory();
      final String path =
          "${directory.path}/event_${DateTime.now().millisecondsSinceEpoch}.png";
      final File imageFile = File(path);
      await imageFile.writeAsBytes(image);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text:
            "Check out this amazing event '${singleEvent!.data!.title}' on Gathering App! 🎈",
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      debugPrint("Detailed Error sharing: $e");
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message: "Share failed: ${e.toString().split('\n').first}",
          isError: true,
        );
      }
    }
  }

  Widget _buildShareCard(Data event) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 400.w,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141124) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: event.images != null && event.images!.isNotEmpty
                ? Image.network(
                    event.images!.first.startsWith('http')
                        ? event.images!.first
                        : "${Urls.baseUrl}${event.images!.first.startsWith('/') ? '' : '/'}${event.images!.first}",
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/container_img.png',
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(height: 16.h),
          // Title
          Text(
            event.title ?? "Untitled Event",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFFB026FF),
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  event.address ?? "Location TBD",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey, size: 14.sp),
              SizedBox(width: 8.w),
              Text(
                _formatEventDateTime(event.startDate, event.startTime),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              // Price Tag
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFB026FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  event.price != null && event.price!.isNotEmpty
                      ? "\$${event.price}"
                      : "FREE",
                  style: TextStyle(
                    color: const Color(0xFFB026FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Branding Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color(0xFFB026FF),
                size: 14.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Gathering App",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB026FF),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventDetailsController>(
      builder: (context, controller, child) {
        singleEvent = controller.singleEvent;

        if (controller.inProgress) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(8.r),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(8.r),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: Consumer<SavedEventController>(
                    builder: (context, savedController, child) {
                      // Construct EventData from SingleEventDataModel
                      final eventData = EventData(
                        id: singleEvent?.data?.id ?? singleEvent?.data?.sId,
                        title: singleEvent?.data?.title,
                        description: singleEvent?.data?.description,
                        category: singleEvent?.data?.category,
                        startDate: singleEvent?.data?.startDate != null
                            ? DateTime.tryParse(singleEvent!.data!.startDate!)
                            : null,
                        address: singleEvent?.data?.address,
                        images: singleEvent?.data?.images,
                        price: singleEvent?.data?.price,
                      );

                      final isSaved = savedController.isSaved(eventData);

                      return IconButton(
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.red : Colors.white,
                        ),
                        onPressed: () {
                          if (eventData.id != null) {
                            savedController.toggleSave(eventData);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.r),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: _shareEventImage,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // HEADER
                    _buildHeader(),
                    SizedBox(height: 20.h),

                    // INFO TAGS ROW (Tonight, Music, etc.)
                    _buildInfoTagsRow(),
                    SizedBox(height: 16.h),

                    // STATUS ROW
                    _buildStatusRow(),
                    SizedBox(height: 24.h),

                    // INFO SECTION
                    _buildInfoSection(),
                    SizedBox(height: 32.h),

                    // TONIGHT'S CHAT
                    _buildChatSection(),
                    SizedBox(height: 32.h),

                    // LOCATION & PERKS
                    _buildLocationAndPerks(),
                    SizedBox(height: 32.h),

                    // REVIEWS
                    _buildReviewsSection(),
                    SizedBox(
                      height: 200.h,
                    ), // Extra space for sticky bar + chat banner
                  ],
                ),
              ),
              // STICKY BOTTOM BUTTONS
              _buildBottomButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 300.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
            image: DecorationImage(
              image:
                  singleEvent?.data?.images != null &&
                      singleEvent!.data!.images!.isNotEmpty
                  ? NetworkImage(
                      singleEvent!.data!.images!.first.startsWith('http')
                          ? singleEvent!.data!.images!.first
                          : "${Urls.baseUrl}${singleEvent!.data!.images!.first.startsWith('/') ? '' : '/'}${singleEvent!.data!.images!.first}",
                    )
                  : AssetImage('assets/images/container_img.png')
                        as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient Overlay for readability
        Container(
          height: 300.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
              ],
              stops: [0.0, 0.5, 0.7, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 50.h,
          left: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "OPEN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      "LIVE • ${singleEvent?.data?.title ?? ''}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (singleEvent?.data?.views != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.white70,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${singleEvent!.data!.views}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey, size: 16.sp),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      singleEvent?.data?.address ?? 'Location info unavailable',
                      style: TextStyle(
                        color: Colors.grey.shade200,
                        fontSize: 14.sp,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTagsRow() {
    List<String> displayTags = [];
    if (singleEvent?.data?.category != null) {
      displayTags.add(singleEvent!.data!.category!);
    }
    if (singleEvent?.data?.tags != null) {
      displayTags.addAll(singleEvent!.data!.tags!.take(2));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildInfoTag(Icons.access_time, "Tonight"),
          SizedBox(width: 8.w),
          ...displayTags.map(
            (tag) => Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: _buildInfoTag(_getCategoryIcon(tag), tag),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFB026FF).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFB026FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFB026FF), size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    category = category.toLowerCase();
    if (category.contains('music')) return Icons.music_note;
    if (category.contains('bar')) return Icons.local_bar;
    if (category.contains('club')) return Icons.nightlife;
    if (category.contains('party')) return Icons.celebration;
    if (category.contains('food')) return Icons.restaurant;
    return Icons.star_border;
  }

  Widget _buildStatusRow() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? const Color(0xFF141124).withOpacity(0.95)
        : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark
        ? const Color(0xFFA294F9)
        : const Color(0xFF7E57C2); // Darker purple for light mode contrast
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 65.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            // Center Bottom Blur Glow
            BoxShadow(
              color: const Color(0xFFB026FF).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Section 1: Busy Now (Horizontal)
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("🔥", style: TextStyle(fontSize: 20.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    "Busy Now",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            _buildVerticalDivider(isDark),
            // Section 2: Vibe (Vertical)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "4.8",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFC107),
                        size: 10.sp,
                      ),
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFC107),
                        size: 10.sp,
                      ),
                    ],
                  ),
                  Text(
                    "Vibe",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildVerticalDivider(isDark),
            // Section 3: Cover (Vertical)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    singleEvent?.data?.price != null &&
                            singleEvent!.data!.price!.isNotEmpty
                        ? "\$${singleEvent!.data!.price}"
                        : "TBA",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Cover",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 35.h,
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.05),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "Info:",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.access_time,
            "Event Time : ",
            _formatEventDateTime(
              singleEvent?.data?.startDate,
              singleEvent?.data?.startTime,
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.person_outline,
            "Organizer : ",
            singleEvent?.data?.organizerId?.name ?? "Host",
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.email_outlined,
            "Email : ",
            singleEvent?.data?.organizerId?.email ?? "Contact Organizer",
          ),
          SizedBox(height: 12.h),
          if (singleEvent?.data?.capacity != null) ...[
            _buildInfoRow(
              Icons.people_outline,
              "Capacity : ",
              "${singleEvent!.data!.capacity} people",
            ),
            SizedBox(height: 12.h),
          ],
          SizedBox(height: 16.h),
          Text(
            "About",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            singleEvent?.data?.description ?? "No description available",
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 18.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.black87,
              ),
              children: [
                if (label.isNotEmpty)
                  TextSpan(
                    text: label,
                    style: TextStyle(color: Colors.grey),
                  ),
                TextSpan(
                  text: value,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Color(0xFFB026FF),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Tonight's Chat",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            "Messages reset nightly, local only",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          Consumer<LiveChatController>(
            builder: (context, chatController, child) {
              if (!_isCheckedIn) {
                return Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: Colors.grey, size: 30.sp),
                      SizedBox(height: 8.h),
                      Text(
                        "Check in to join the conversation!",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                height: 400.h, // Fixed height for chat area
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.all(12.r),
                child: Column(
                  children: [
                    Expanded(
                      child:
                          chatController.isLoading &&
                              chatController.messages.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : chatController.messages.isEmpty
                          ? Center(
                              child: Text(
                                "No messages yet. Start the conversation!",
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              reverse: true, // Show newest at bottom
                              itemCount: chatController.messages.length,
                              itemBuilder: (context, index) {
                                final msg = chatController.messages[index];
                                return _buildChatMessage(msg);
                              },
                            ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 14.sp,
                              ),
                              cursorColor: Color(0xFFB026FF),
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.h,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          InkWell(
                            onTap: _sendMessage,
                            borderRadius: BorderRadius.circular(30.r),
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: Color(0xFFB026FF),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFB026FF).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    // success handled by controller (optimistic or wait)
    final success = await context.read<LiveChatController>().sendMessage(
      eventId,
      text,
    );
    if (!success) {
      if (mounted) {
        showCustomSnackBar(
          context: context,
          message:
              context.read<LiveChatController>().errorMessage ??
              "Failed to send",
          isError: true,
        );
      }
    }
  }

  Widget _buildChatMessage(LiveChatMessageModel msg) {
    final currentUserId = AuthController().userId;
    // Determine if the message is sent by me
    final isMe =
        (msg.userId != null && msg.userId == currentUserId) ||
        (msg.userProfile?.id != null && msg.userProfile!.id == currentUserId);

    if (isMe) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h, left: 50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Color(0xFFB026FF).withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.zero,
                ),
                border: Border.all(color: Color(0xFFB026FF).withOpacity(0.5)),
              ),
              child: Text(
                msg.message ?? "",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.formattedTime ?? "",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
                if (msg.likes != null && msg.likes! > 0) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.favorite, size: 10.sp, color: Colors.red),
                  SizedBox(width: 2.w),
                  Text(
                    "${msg.likes}",
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage:
                msg.userProfile?.avatar != null &&
                    msg.userProfile!.avatar!.isNotEmpty
                ? NetworkImage(
                    msg.userProfile!.avatar!.startsWith('http')
                        ? msg.userProfile!.avatar!
                        : "${Urls.baseUrl}${msg.userProfile!.avatar}",
                  )
                : null,
            child:
                msg.userProfile?.avatar == null ||
                    msg.userProfile!.avatar!.isEmpty
                ? Icon(Icons.person, size: 20.sp, color: Colors.grey)
                : null,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      msg.userProfile?.name ?? "User",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      msg.formattedTime ?? "",
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    msg.message ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (msg.id != null) {
                          context.read<LiveChatController>().likeMessage(
                            msg.id!,
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            msg.hasLiked == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14.sp,
                            color: msg.hasLiked == true
                                ? Colors.red
                                : Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          if (msg.likes != null && msg.likes! > 0)
                            Text(
                              "${msg.likes}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    if (currentUserId == msg.userId ||
                        (msg.userProfile?.id != null &&
                            msg.userProfile!.id == currentUserId))
                      GestureDetector(
                        onTap: () {
                          if (msg.id != null) {
                            _confirmDelete(msg.id!);
                          }
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.redAccent,
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
    );
  }

  Widget _buildLocationAndPerks() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_pin, color: Colors.grey, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                "Location & Perks",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              height: 250.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Stack(
                children: [
                  if (singleEvent?.data?.location?.coordinates != null &&
                      singleEvent!.data!.location!.coordinates!.length >= 2)
                    Consumer<MapController>(
                      builder: (context, mapCtrl, child) {
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              singleEvent!.data!.location!.coordinates![1],
                              singleEvent!.data!.location!.coordinates![0],
                            ),
                            zoom: 15,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            mapCtrl.setMapController(controller);
                            _applyMapStyle();

                            // Automatically show route in-app
                            final lat =
                                singleEvent!.data!.location!.coordinates![1];
                            final lng =
                                singleEvent!.data!.location!.coordinates![0];
                            mapCtrl.showRouteToEvent(LatLng(lat, lng));
                          },
                          markers: mapCtrl.markers,
                          polylines: mapCtrl.polylines,
                          zoomControlsEnabled: false,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                        );
                      },
                    )
                  else
                    Center(child: Text("Location not available")),

                  // Zoom Controls
                  Positioned(
                    right: 12.w,
                    bottom: 12.h,
                    child: Column(
                      children: [
                        _buildZoomButton(Icons.add, () {
                          _mapController?.animateCamera(CameraUpdate.zoomIn());
                        }),
                        SizedBox(height: 8.h),
                        _buildZoomButton(Icons.remove, () {
                          _mapController?.animateCamera(CameraUpdate.zoomOut());
                        }),
                      ],
                    ),
                  ),

                  // Open in Maps Button (Overlay)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12.h,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _openInMaps();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Consumer<MapController>(
                            builder: (context, mapCtrl, child) {
                              if (mapCtrl.isRouting)
                                return SizedBox(
                                  height: 16.sp,
                                  width: 16.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                );
                              return RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    const TextSpan(text: "Get Direction"),
                                    if (mapCtrl.duration != null)
                                      TextSpan(
                                        text: " (${mapCtrl.duration})",
                                        style: const TextStyle(
                                          color: Color(
                                            0xFF1DB954,
                                          ), // Friendly Green
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (singleEvent?.data?.address != null &&
              singleEvent!.data!.address!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Color(0xFFB026FF), size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    singleEvent!.data!.address!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          Text(
            "Perks",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 4,
            children: [
              _buildPerkItem(Icons.local_bar, "Craft Cocktails"),
              _buildPerkItem(Icons.waves, "LED Light Show"),
              _buildPerkItem(Icons.music_note, "Live DJ"),
              _buildPerkItem(Icons.cloud, "Hookah Available"),
              _buildPerkItem(Icons.wine_bar, "VIP Bottle Service"),
              _buildPerkItem(Icons.security, "Security on Site"),
              _buildPerkItem(Icons.deck, "Outdoor Patio"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFB026FF), size: 18.sp),
        SizedBox(width: 10.w),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Color(0xFFB026FF), size: 20.sp),
      ),
    );
  }

  Future<void> _applyMapStyle() async {
    if (_mapController == null) return;
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final String stylePath = isDark
          ? 'assets/map_dark_style.json'
          : 'assets/map_style.json';
      final String style = await DefaultAssetBundle.of(
        context,
      ).loadString(stylePath);
      await _mapController!.setMapStyle(style);
    } catch (e) {
      debugPrint("Error applying map style: $e");
    }
  }

  String _formatEventDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null) return "Date TBA";
    try {
      final date = DateTime.parse(dateStr);
      final dateFormatter = DateFormat('MMM dd, yyyy');
      String result = dateFormatter.format(date);

      if (timeStr != null && timeStr.isNotEmpty) {
        try {
          // Try to parse timeStr as a full ISO DateTime
          final time = DateTime.parse(timeStr);
          final timeFormatter = DateFormat('hh:mm a');
          result += " at ${timeFormatter.format(time)}";
        } catch (_) {
          // Fallback to raw string if not a valid ISO date
          result += " at $timeStr";
        }
      }
      return result;
    } catch (e) {
      return dateStr + (timeStr != null ? " $timeStr" : "");
    }
  }

  Widget _buildReviewsSection() {
    return Consumer<ReivewController>(
      builder: (context, reviewCtrl, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Builder(
            builder: (context) {
              // Calculate average rating
              double avgRating = 0.0;
              if (reviewCtrl.review.isNotEmpty) {
                avgRating =
                    reviewCtrl.review
                        .map((e) => e.rating)
                        .reduce((a, b) => a + b) /
                    reviewCtrl.review.length;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //HEADER with Rating and Crowd Favorite
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            avgRating == 0.0
                                ? "0.0"
                                : avgRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 48.sp,
                              fontWeight: FontWeight.bold,
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
                                size: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "${reviewCtrl.totalReview} check-ins & reviews",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Crowd Favorite",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  "Based on activity",
                                  style: TextStyle(
                                    fontSize: 10.sp,
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
                  SizedBox(height: 24.h),

                  // Vibe Summary
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vibe Summary",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Guests say this spot has a high-energy crowd, great DJs, and strong late-night vibes. Most reviews mention good music and cocktails.",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.grey,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "Automatically summarized from reviews",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "Most Helpful Tonight",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => WriteReviewAlertDialogue(context),
                        child: Text(
                          "Write Review",
                          style: TextStyle(
                            color: const Color(0xFFB026FF),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  if (reviewCtrl.inProgress)
                    const Center(child: CircularProgressIndicator())
                  else if (reviewCtrl.review.isEmpty)
                    const Center(child: Text("No reviews yet"))
                  else
                    SizedBox(
                      height: 180.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: reviewCtrl.review.length,
                        itemBuilder: (context, index) {
                          return _buildHorizontalReviewCard(
                            reviewCtrl.review[index],
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 24.h),
                  Center(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25.r),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllReviewsScreen(eventId: eventId),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Show all ${reviewCtrl.totalReview} reviews",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward_ios, size: 12.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHorizontalReviewCard(AllReviewModelByEventId review) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 250.w,
      margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
        //     blurRadius: 10,
        //     offset: Offset(0, 4),
        //   ),
        // ],
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB026FF).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18.r,
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
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              SizedBox(width: 4.w),
                              Text(
                                _formatReviewTime(review.createdAt),
                                style: TextStyle(
                                  fontSize: 10.sp,
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
                Expanded(
                  child: Text(
                    review.review,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.3,
                      color: isDark ? Colors.grey.shade300 : Colors.black54,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Event Identity Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 12.r,
                  backgroundImage:
                      singleEvent?.data?.images != null &&
                          singleEvent!.data!.images!.isNotEmpty
                      ? NetworkImage(
                          "${Urls.baseUrl}${singleEvent!.data!.images!.first}",
                        )
                      : AssetImage('assets/images/container_img.png')
                            as ImageProvider,
                ),
                SizedBox(width: 8.w),
                Text(
                  singleEvent?.data?.title ?? "Event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isCheckedIn = !_isCheckedIn;
                        if (_isCheckedIn) {
                          context.read<LiveChatController>().joinRoom(eventId);
                          context.read<LiveChatController>().fetchMessages(
                            eventId,
                          );
                        } else {
                          context.read<LiveChatController>().leaveRoom();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory, // Disable ripple
                      overlayColor: Color(
                        0xFF2E7D32,
                      ).withOpacity(0.1), // Subtle highlight
                      backgroundColor: _isCheckedIn
                          ? Color(0xFF2E7D32).withOpacity(0.15)
                          : Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: Color(0xFF2E7D32).withOpacity(0.3),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCheckedIn
                              ? Icons.check
                              : Icons.location_on_outlined,
                          color: Color(0xFF2E7D32),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isCheckedIn ? "Checked In" : "Check In",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (singleEvent?.data?.location?.coordinates != null &&
                          singleEvent!.data!.location!.coordinates!.length >=
                              2) {
                        final lat =
                            singleEvent!.data!.location!.coordinates![1];
                        final lng =
                            singleEvent!.data!.location!.coordinates![0];
                        final url =
                            "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } else if (singleEvent?.data?.address != null) {
                        final query = Uri.encodeComponent(
                          singleEvent!.data!.address!,
                        );
                        final url =
                            "https://www.google.com/maps/search/?api=1&query=$query";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory, // Disable ripple
                      overlayColor: Color(
                        0xFFB026FF,
                      ).withOpacity(0.1), // Subtle highlight
                      backgroundColor: Color(0xFFB026FF).withOpacity(0.15),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: Color(0xFFB026FF).withOpacity(0.3),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.near_me,
                          color: Color(0xFFB026FF),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Get Directions",
                          style: TextStyle(
                            color: Color(0xFFB026FF),
                            fontWeight: FontWeight.bold,
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
    );
  }

  void WriteReviewAlertDialogue(BuildContext context) {
    double rating = 5.0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text("Write a Review", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: 5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30.sp,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (r) {
                  rating = r;
                },
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFFB026FF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFFB026FF), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            Consumer<ReivewController>(
              builder: (context, reviewCtrl, child) {
                return ElevatedButton(
                  onPressed: reviewCtrl.inProgress
                      ? null
                      : () async {
                          final success = await reviewCtrl.submitReview(
                            eventId: eventId,
                            reviewText: reviewController.text,
                            rating: rating,
                          );
                          if (success) {
                            Navigator.pop(context);
                            reviewCtrl.getAllReviewsByEventId(eventId: eventId);
                            showCustomSnackBar(
                              context: context,
                              message: "Review submitted successfully!",
                              isError: false,
                            );
                          } else {
                            showCustomSnackBar(
                              context: context,
                              message:
                                  reviewCtrl.errorMessage ??
                                  "Failed to submit review",
                              isError: true,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB026FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: reviewCtrl.inProgress
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text("Submit", style: TextStyle(color: Colors.white)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatReviewTime(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final reviewDate = DateTime(localDate.year, localDate.month, localDate.day);

    String hour = localDate.hour > 12
        ? (localDate.hour - 12).toString()
        : localDate.hour.toString();
    if (hour == '0') hour = '12';
    String minute = localDate.minute.toString().padLeft(2, '0');
    String period = localDate.hour >= 12 ? 'PM' : 'AM';
    String timeStr = "$hour:$minute $period";

    if (reviewDate == today) return timeStr;
    if (reviewDate == yesterday) return "Yesterday at $timeStr";

    String month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][localDate.month - 1];
    return "$month ${localDate.day} at $timeStr";
  }

  void _confirmDelete(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await context
                  .read<LiveChatController>()
                  .deleteMessage(messageId);
              if (!success) {
                if (mounted) {
                  showCustomSnackBar(
                    context: context,
                    message: "Failed to delete",
                    isError: true,
                  );
                }
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
