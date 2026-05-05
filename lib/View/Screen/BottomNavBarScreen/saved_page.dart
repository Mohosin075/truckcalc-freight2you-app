import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gathering_app/View/Widgets/custom_item_container.dart';
import 'package:gathering_app/View/view_controller/saved_event_controller.dart';
import 'package:provider/provider.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  // EventCartmodel event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saved Events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10.h),
              Consumer<SavedEventController>(
                builder: (context, controller, child) {
                  return Text(
                    '${controller.savedEvents.length} events saved',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                },
              ),
              SizedBox(height: 10.h),
              // Expanded(
              Expanded(
                child: Consumer<SavedEventController>(
                  builder: (context, controller, child) {
                    if (controller.inProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.savedEvents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border, size: 60.sp, color: Colors.grey),
                            SizedBox(height: 10.h),
                            Text(
                              "No saved events yet",
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                        itemCount: controller.savedEvents.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.80,
                          mainAxisSpacing: 16.w,
                          crossAxisSpacing: 16.w,
                        ),
                        itemBuilder: (context, index) {
                          final savedEventData = controller.savedEvents[index];
                          return Custom_item_container(
                             event: savedEventData.event,
                             onTap: () => Navigator.pushNamed(
                                      context,
                                      '/details-screen', 
                                      arguments: savedEventData.event.id,
                                    ),
                          );
                        },
                      );
                  }
                ),
              ),
              //     //       );
              //     //     },
              //     //   );
              //     }
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
