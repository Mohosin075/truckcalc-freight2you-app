import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchTextField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool? autoFocus;

  SearchTextField({
    super.key,
    this.icon,
    required this.hintText,
    this.obscureText = false,
    this.onChanged,
    this.onClear,
    this.autoFocus,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // main container
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF250143) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: TextFormField(
              // autofocus: autoFocus,
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16.sp,
              ),
              cursorColor: const Color(0xFFCC18CA),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white60 : const Color(0xFF515151),
                  fontSize: 15.sp.clamp(15, 16),
                ),
                suffixIcon: icon != null
                    ? Icon(
                        icon,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF515151),
                        size: 22.w,
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 18.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
