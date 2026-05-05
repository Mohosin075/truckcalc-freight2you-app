import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactOrgenizerButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback? onPressed;
  final bool isLoading;

  const ContactOrgenizerButton({
    super.key,
    required this.buttonName,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        splashColor: const Color(0xFFCC18CA).withOpacity(0.3),
        highlightColor: const Color(0xFFCC18CA).withOpacity(0.1),
        onTap: onPressed,
        child: Container(
          height: 56.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color.fromARGB(255, 0, 0, 0)           
                : Colors.white,                     // Light mode এ সাদা
            borderRadius: BorderRadius.circular(16.r),
            // border: Border.all(
            //   color: isDark
            //       ? Colors.white.withOpacity(0.2)
            //       : Colors.grey.shade300,
            //   width: 1.2,
            // ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white : const Color(0xFF8063F4),
                      strokeWidth: 3,
                    ),
                  )
                : Text(
              buttonName,
              style: TextStyle(
                fontSize: 16.sp.clamp(16, 18),
                fontWeight: FontWeight.w700,
                // টেক্সট কালার অটো
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}