import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../Theme/theme_provider.dart';
class DetailsHighlightMessage extends StatelessWidget {

  final String message;
  const DetailsHighlightMessage({
    super.key,
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, controller, child) => SizedBox(
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(width: 1, color:  Color(0xFFB026FF).withOpacity(0.15))
          ),
          child: ListTile(
            leading: Container(
              height: 10.h,
              width: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink,
              ),
            ),
            title: Text(
              message,
              style: TextStyle(
                color: controller.isDarkMode
                    ? Color(0xFFF0F0F5)
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
