import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class common_appbar extends StatelessWidget implements PreferredSizeWidget {
  final String titleName;

  const common_appbar({
    super.key,
    required this.titleName,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 36.r,
            width: 36.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF3E043F)
                  : const Color(0xFF686868),
            ),
            child: Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
      ),
      title: Text(
        titleName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
  @override
  Size get preferredSize => Size.fromHeight(70);
}