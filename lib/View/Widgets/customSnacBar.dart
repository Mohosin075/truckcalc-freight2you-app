import 'package:flutter/material.dart';
import 'package:gathering_app/Utils/app_utils.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  AppUtils.scaffoldMessengerKey.currentState?.clearSnackBars();

  AppUtils.scaffoldMessengerKey.currentState?.showSnackBar(
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
            onTap: () => AppUtils.scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
      backgroundColor: isError
          ? const Color(0xFFE74C3C)
          : const Color(0xFFCC18CA),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: () {
          // Use provided context only if it's active
          if (context.mounted) {
            try {
              return MediaQuery.of(context).size.height * 0.1;
            } catch (e) {
              debugPrint("CustomSnackBar: MediaQuery failed with context: $e");
            }
          }
          
          // Fallback to global navigator context
          final globalCtx = AppUtils.navigatorKey.currentContext;
          if (globalCtx != null && globalCtx.mounted) {
            try {
              return MediaQuery.of(globalCtx).size.height * 0.1;
            } catch (e) {
              debugPrint("CustomSnackBar: MediaQuery failed with globalCtx: $e");
            }
          }
          
          return 80.0; // Hard fallback
        }(),
        left: 20,
        right: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      duration: duration,
      animation: CurvedAnimation(
        parent: const AlwaysStoppedAnimation(1),
        curve: Curves.easeOutCubic,
      ),
    ),
  );
}
