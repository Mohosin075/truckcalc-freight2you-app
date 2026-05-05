import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gathering_app/Service/Controller/bottom_nav_controller.dart';
import 'package:gathering_app/Service/Controller/create_event_controller.dart';
import 'package:gathering_app/Service/Controller/getAllEvent_controller.dart';
import 'package:gathering_app/Service/Controller/user_event_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/map_page.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final List<File> _selectedImages = [];
  bool _isPublic = true;
  String _rsvpRequirement = "21+";

  // State for Date/Time and Location
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedVibe;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    _titleFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFFB026FF),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    _titleFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFFB026FF),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _selectVibe() {
    _titleFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    final List<String> vibes = [
      "Gathering",
      "Celebration",
      "Day Party",
      "Party",
      "Kickback",
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Vibe",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vibes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        vibes[index],
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black87,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedVibe = vibes[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _selectedImages.clear();
      _selectedDate = null;
      _selectedTime = null;
      _selectedLocation = null;
      _selectedLat = null;
      _selectedLng = null;
      _selectedVibe = null;
      _isPublic = true;
    });
  }

  Timer? _debounce;

  Future<void> _selectLocation() async {
    _titleFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    _showLocationSearchModal();
  }

  void _showLocationSearchModal() {
    final controller = Provider.of<CreateEventController>(
      context,
      listen: false,
    );
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Search Location",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Search Bar
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search local area...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        controller.searchLocation(value).then((_) {
                          setModalState(() {});
                        });
                      });
                    },
                  ),
                  SizedBox(height: 10.h),
                  // Map Option
                  ListTile(
                    leading: const Icon(Icons.map, color: Color(0xFFB026FF)),
                    title: const Text(
                      "Pick on Map",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Manually select a location"),
                    onTap: () async {
                      Navigator.pop(context); // Close search modal
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapPage(isPicker: true),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _selectedLat = result['lat'];
                          _selectedLng = result['lng'];
                          _selectedLocation = result['address'];
                        });
                      }
                    },
                  ),
                  const Divider(),
                  // Results
                  Expanded(
                    child: Consumer<CreateEventController>(
                      builder: (context, ctrl, _) {
                        if (ctrl.inProgress) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (ctrl.locationSuggestions.isEmpty) {
                          return Center(
                            child: Text(
                              searchController.text.isEmpty
                                  ? "Type to search..."
                                  : "No results found",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: ctrl.locationSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = ctrl.locationSuggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: Text(suggestion.address ?? "Unknown"),
                              onTap: () {
                                setState(() {
                                  _selectedLocation = suggestion.address;
                                  _selectedLat = suggestion.location?.latitude;
                                  _selectedLng = suggestion.location?.longitude;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitEvent(CreateEventController controller) async {
    // Removal of unused lat/lng variables as selected position is now handled by _selectedLat/_selectedLng
    // final mapCtrl = Provider.of<MapController>(context, listen: false);
    // double lat = mapCtrl.currentPosition?.latitude ?? 23.8103;
    // double lng = mapCtrl.currentPosition?.longitude ?? 90.4125;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final DateTime combined = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Strict ISO 8601 with Z for the server
    final String startDateStr = combined.toUtc().toIso8601String();
    final String startTimeStr = combined
        .add(const Duration(hours: 3))
        .toUtc()
        .toIso8601String();

    final eventData = {
      "title": _titleController.text.isNotEmpty
          ? _titleController.text
          : "Tech Meetup 2026",
      "startDate": startDateStr,
      "startTime": startTimeStr,
      "vibeTags": _selectedVibe != null
          ? [_selectedVibe!.toLowerCase()]
          : ["tech", "networking", "startup"],
      "visibility": _isPublic,
      "rsvp": _rsvpRequirement,
      "address": _selectedLocation ?? "Banani, Dhaka, Bangladesh",
      "location": {
        "type": "Point",
        "coordinates": [_selectedLng ?? 90.4125, _selectedLat ?? 23.8103],
      },
    };

    final success = await controller.createEvent(eventData, _selectedImages);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      _resetForm();

      // Auto-refresh event lists
      context.read<GetAllEventController>().getAllEvents();
      context.read<UserEventController>().fetchUserEvents();

      context.read<BottomNavController>().onItemTapped(0);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to create event'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFFB026FF);
    final Color containerColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : const Color(0xFFF5F5F7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80.w,

        title: Text(
          "Create Event",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CreateEventController>(
            builder: (context, createCtrl, child) {
              return TextButton(
                onPressed:
                    (_titleController.text.isNotEmpty &&
                        _selectedLocation != null &&
                        _selectedDate != null &&
                        _selectedTime != null &&
                        _selectedVibe != null &&
                        !createCtrl.inProgress)
                    ? () => _submitEvent(createCtrl)
                    : null,
                child: createCtrl.inProgress
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        "Create",
                        style: TextStyle(
                          color:
                              (_titleController.text.isNotEmpty &&
                                  _selectedLocation != null &&
                                  _selectedDate != null &&
                                  _selectedTime != null &&
                                  _selectedVibe != null)
                              ? primaryColor
                              : Colors.grey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              // --- Image Upload Section ---
              if (_selectedImages.isEmpty)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: primaryColor,
                                size: 32.sp,
                              ),
                              Text(
                                "Tap to Upload Photos",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 140.w,
                            margin: EdgeInsets.only(right: 12.w),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Icon(
                              Icons.add,
                              color: primaryColor,
                              size: 32.sp,
                            ),
                          ),
                        );
                      }
                      return Container(
                        width: 160.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              margin: EdgeInsets.all(8.r),
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 24.h),

              // --- Event Title ---
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: const Color(0xFFB026FF),
                      size: 24.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        maxLength: 50,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () => _titleFocusNode.unfocus(),
                        onChanged: (val) => setState(() {}),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Event Title",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14.sp,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          counterText: "",
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildClickableField(
                icon: Icons.location_on,
                title: "Location",
                subtitle: _selectedLocation ?? "Where's it at?",
                onTap: _selectLocation,
              ),

              _buildClickableField(
                icon: Icons.calendar_today,
                title: "Date",
                subtitle: _selectedDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!)
                    : "When's it happening?",
                onTap: _pickDate,
              ),

              _buildClickableField(
                icon: Icons.access_time,
                title: "Time",
                subtitle: _selectedTime != null
                    ? _selectedTime!.format(context)
                    : "What time?",
                onTap: _pickTime,
              ),

              _buildClickableField(
                icon: Icons.music_note,
                title: "Music & Vibes",
                subtitle: _selectedVibe ?? "Select vibe",
                onTap: _selectVibe,
              ),

              SizedBox(height: 24.h),

              Text(
                "Visibility & Access",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.h),

              Container(
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Text("🔥", style: TextStyle(fontSize: 20.sp)),
                      title: Text(
                        "Make Event Public",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "Anyone nearby can find & join this event",
                        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                      ),
                      trailing: Switch(
                        value: _isPublic,
                        onChanged: (val) => setState(() => _isPublic = val),
                        activeColor: primaryColor,
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.05),
                      indent: 50.w,
                    ),
                    _buildSubSettingTile(
                      icon: Icons.alternate_email,
                      title: "Invite Friends",
                      subtitle: "Invite people directly",
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.05),
                      indent: 50.w,
                    ),
                    _buildSubSettingTile(
                      icon: Icons.badge_outlined,
                      title: "RSVP Requirements",
                      subtitle: _rsvpRequirement,
                      onTap: () {
                        _titleFocusNode.unfocus();
                        FocusScope.of(context).unfocus();
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          builder: (context) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "RSVP Requirements",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  ListTile(
                                    title: const Text(
                                      "18+",
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () {
                                      setState(() => _rsvpRequirement = "18+");
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: const Text(
                                      "21+",
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () {
                                      setState(() => _rsvpRequirement = "21+");
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableField({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color containerColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : const Color(0xFFF5F5F7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB026FF), size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFFB026FF), size: 20.sp),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey, fontSize: 11.sp),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey, size: 18.sp),
    );
  }
}
