import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truckcalc/View/Widgets/app_background.dart';
import 'package:truckcalc/View/Widgets/custom_item_container.dart';
import 'package:truckcalc/View/view_controller/saved_event_controller.dart';
import 'package:provider/provider.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});
  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text('Saved Events', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 20.h),
                Expanded(
                  child: Consumer<SavedEventController>(
                    builder: (context, controller, child) {
                      if (controller.inProgress) return const Center(child: CircularProgressIndicator(color: Color(0xFF00D193)));
                      if (controller.savedEvents.isEmpty) return const Center(child: Text("No saved events", style: TextStyle(color: Colors.white38)));
                      return GridView.builder(
                        itemCount: controller.savedEvents.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, mainAxisSpacing: 16.w, crossAxisSpacing: 16.w),
                        itemBuilder: (context, index) {
                          final event = controller.savedEvents[index].event;
                          return Custom_item_container(
                            event: event,
                            onTap: () => Navigator.pushNamed(context, '/view-event-screen', arguments: event.id),
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
      ),
    );
  }
}
