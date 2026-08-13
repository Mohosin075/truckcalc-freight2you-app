import 'package:flutter/material.dart';
import 'package:truckcalc/Utils/app_utils.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  final scaffoldMessenger = AppUtils.scaffoldMessengerKey.currentState ??
      ScaffoldMessenger.maybeOf(context);

  // Pre-calculate bottom margin using safe context-free platformDispatcher to prevent "deactivated widget's ancestor" exceptions.
  double bottomMargin = 80.0;
  try {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    bottomMargin = screenHeight * 0.1;
  } catch (_) {
    bottomMargin = 80.0;
  }

  scaffoldMessenger?.clearSnackBars();

  scaffoldMessenger?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // টেক্সট
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              try {
                scaffoldMessenger.hideCurrentSnackBar();
              } catch (_) {}
              try {
                ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
              } catch (_) {}
              try {
                AppUtils.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
              } catch (_) {}
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError
          ? const Color(0xFFE74C3C)
          : const Color(0xFFCC18CA),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: bottomMargin,
        left: 20,
        right: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      duration: duration,
    ),
  );
}
