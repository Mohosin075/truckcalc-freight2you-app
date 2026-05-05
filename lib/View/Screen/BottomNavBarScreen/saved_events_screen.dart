import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/Service/Controller/bottom_nav_controller.dart';
import 'package:gathering_app/View/Screen/BottomNavBarScreen/details_screen.dart';
import 'package:gathering_app/View/Widgets/custom_item_container.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:provider/provider.dart';

class SavedEventsScreen extends StatefulWidget {
  const SavedEventsScreen({super.key});

  static const String name = '/saved-events-screen';

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends State<SavedEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedEventController>().loadMySavedEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Saved Events",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<SavedEventController>(
        builder: (context, savedController, child) {
          if (savedController.inProgress &&
              savedController.savedEvents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (savedController.savedEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80.sp,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No saved events yet 💾',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BottomNavController>().onItemTapped(0);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB026FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: const Text(
                      'Explore Events',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => savedController.loadMySavedEvents(),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: savedController.savedEvents.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 0.80, // Same as HomePage
              ),
              itemBuilder: (context, index) {
                final savedItem = savedController.savedEvents[index];
                final event = savedItem.event;

                return Custom_item_container(
                  event: event,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      DetailsScreen.name,
                      arguments: event.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
