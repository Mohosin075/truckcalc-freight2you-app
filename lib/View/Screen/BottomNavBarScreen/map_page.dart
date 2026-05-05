import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Model/get_all_event_model.dart';
import 'package:gathering_app/Service/Controller/map_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/details_screen.dart';
import 'package:gathering_app/View/Theme/theme_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gathering_app/Service/urls.dart';
import 'package:gathering_app/View/Widgets/serch_textfield.dart';

class MapPage extends StatefulWidget {
  final bool isPicker;
  const MapPage({super.key, this.isPicker = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _localMapController;
  String? _lastSelectedEventId;
  LatLng? _pickedLocation;
  String? _pickedAddress;
  // _selectedCategory is now managed by MapController to sync with logic

  @override
  void initState() {
    super.initState();
    context.read<MapController>().addListener(_updateUI);
  }

  void _updateUI() {
    if (!mounted) return;
    final mapCtrl = context.read<MapController>();

    if (mapCtrl.selectedEvent != null) {
      if (mapCtrl.selectedEvent!.id != _lastSelectedEventId) {
        _lastSelectedEventId = mapCtrl.selectedEvent!.id;
      }
    } else {
      _lastSelectedEventId = null;
    }
    setState(() {});
  }

  @override
  void dispose() {
    context.read<MapController>().removeListener(_updateUI);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapController>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        children: [
          // --- Full Screen Map Area ---
          Consumer2<ThemeProvider, MapController>(
            builder: (context, themeProvider, mapCtrl, child) {
              // Trigger style update if map is already created
              mapCtrl.applyMapStyle(themeProvider.isDarkMode);

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(23.8103, 90.4125),
                  zoom: 15,
                ),
                markers: widget.isPicker && _pickedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId("picked_location"),
                          position: _pickedLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueViolet,
                          ),
                        ),
                      }
                    : mapCtrl.markers,
                polylines: mapCtrl.polylines,
                onMapCreated: (controller) {
                  _localMapController = controller;
                  mapCtrl.setMapController(controller);
                  mapCtrl.applyMapStyle(themeProvider.isDarkMode);
                  if (mapCtrl.currentPosition != null) {
                    mapCtrl.moveToCurrentLocation();
                  }
                },
                onTap: (latLng) {
                  if (widget.isPicker) {
                    setState(() {
                      _pickedLocation = latLng;
                      // In a real app, you'd geocode here.
                      // For now, we'll use a placeholder or the MapController's service if it has one.
                      _pickedAddress =
                          "Selected Location (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})";
                    });
                    mapCtrl.clearSelectedEvent();
                  } else {
                    mapCtrl.clearSelectedEvent();
                    setState(() {
                      _lastSelectedEventId = null;
                    });
                  }
                },
                zoomControlsEnabled: false,
                myLocationEnabled: true, // Show user location dot properly
                myLocationButtonEnabled: false,
              );
            },
          ),

          // --- Top Overlays (Header, Search, Filters) ---
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                // --- 1. Centered Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: const Color(0xFFB026FF),
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Gathering',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                // --- 2. Search Bar (Dynamic) ---
                SearchTextField(
                  hintText: "Search events, venues...",
                  onChanged: (query) {
                    mapCtrl.updateSearchQuery(query);
                  },
                ),
                SizedBox(height: 5.h),

                // --- 3. Filter Chips (Dynamic) ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: mapCtrl.categories.map((cat) {
                      return _buildNewFilterChip(
                        cat,
                        _getCategoryIcon(cat),
                        false,
                        isDark,
                        mapCtrl,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // --- Custom Bottom Info Card ---
          if (mapCtrl.selectedEvent != null)
            _buildBottomEventCard(mapCtrl.selectedEvent!, mapCtrl),

          // --- Map Tool Buttons (Zoom / Location) ---
          Positioned(
            bottom: 160.h, // Increased to avoid bottom bar
            right: 20.w,
            child: Column(
              children: [
                _buildMapToolButton(Icons.add, mapCtrl.zoomIn),
                SizedBox(height: 10.h),
                _buildMapToolButton(Icons.remove, mapCtrl.zoomOut),
                SizedBox(height: 10.h),
                _buildMapToolButton(
                  Icons.my_location,
                  mapCtrl.moveToCurrentLocation,
                ),
              ],
            ),
          ),

          // --- Bottom "Vide" Panel ---
          if (mapCtrl.selectedEvent == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF030303),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.list, color: Colors.grey, size: 24.sp),
                    Text(
                      "Vide",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),

          if (mapCtrl.isLoading || mapCtrl.eventsLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFB026FF)),
            ),

          // --- Confirm Selection Button for Picker ---
          if (widget.isPicker && _pickedLocation != null)
            Positioned(
              bottom: 30.h,
              left: 20.w,
              right: 20.w,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'lat': _pickedLocation!.latitude,
                    'lng': _pickedLocation!.longitude,
                    'address': _pickedAddress,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB026FF),
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                child: Text(
                  "Confirm Location",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewFilterChip(
    String label,
    IconData? icon,
    bool isPrimary,
    bool isDark,
    MapController mapCtrl,
  ) {
    bool isSelected = mapCtrl.selectedCategory == label;

    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      backgroundColor = const Color(0xFFB026FF);
      textColor = Colors.white;
    } else {
      backgroundColor = const Color(0xFF1E1E1E).withOpacity(0.9);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        mapCtrl.applyCategoryFilter(label);
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFFB026FF),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData? _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bars':
        return Icons.local_bar;
      case 'clubs':
        return Icons.language; // Or Icons.music_note
      case 'lounges':
        return Icons.wine_bar;
      case 'music':
        return Icons.music_note;
      case 'party':
        return Icons.celebration;
      default:
        return category == "All" ? null : Icons.local_activity;
    }
  }

  Widget _buildMapToolButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildBottomEventCard(EventData event, MapController mapCtrl) {
    return Positioned(
      bottom: 120.h,
      left: 16.w,
      right: 16.w,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, DetailsScreen.name, arguments: event.id);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Left Side: Event Image ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        width: 110.w,
                        height: 110.h,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                event.images != null && event.images!.isNotEmpty
                                ? NetworkImage(
                                    "${Urls.baseUrl}${event.images!.first}",
                                  )
                                : const AssetImage(
                                        'assets/images/container_img.png',
                                      )
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // --- Right Side: Event Info ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5400),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  event.title ?? "Event Title",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.stars,
                                color: const Color(0xFFB026FF),
                                size: 14.sp,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  "Official Gathering Location",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white60,
                                size: 14.sp,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  event.address ?? "Address not available",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (mapCtrl.distance != null) ...[
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.near_me_outlined,
                                  color: const Color(0xFF1DB954),
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${mapCtrl.distance}${mapCtrl.duration != null ? ' (${mapCtrl.duration})' : ''}",
                                  style: TextStyle(
                                    color: const Color(0xFF1DB954),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // --- Bottom Actions ---
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            DetailsScreen.name,
                            arguments: event.id,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB026FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.near_me,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Check In",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: mapCtrl.isRouting
                            ? null
                            : () {
                                if (_localMapController != null) {
                                  mapCtrl.setMapController(
                                    _localMapController!,
                                  );
                                }
                                final lat =
                                    (event.location?.coordinates?[1] as num?)
                                        ?.toDouble() ??
                                    0;
                                final lng =
                                    (event.location?.coordinates?[0] as num?)
                                        ?.toDouble() ??
                                    0;
                                mapCtrl.showRouteToEvent(LatLng(lat, lng));
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (mapCtrl.isRouting)
                              SizedBox(
                                height: 16.sp,
                                width: 16.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else ...[
                              Icon(
                                Icons.directions_outlined,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Direction",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ],
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
    );
  }
}
