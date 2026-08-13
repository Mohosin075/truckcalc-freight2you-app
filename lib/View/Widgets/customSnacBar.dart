import 'dart:async';
import 'package:flutter/material.dart';
import 'package:truckcalc/Utils/app_utils.dart';

OverlayEntry? _currentOverlayEntry;
Timer? _autoDismissTimer;

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  // Dismiss any existing top snackbar immediately
  dismissCustomSnackBar();

  final overlayState = Navigator.of(context).overlay ??
      AppUtils.navigatorKey.currentState?.overlay;

  if (overlayState == null) return;

  // Safe status bar height calculation using global context
  final globalCtx = AppUtils.navigatorKey.currentContext;
  final double statusBarHeight =
      globalCtx != null ? MediaQuery.paddingOf(globalCtx).top : 0.0;

  _currentOverlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: statusBarHeight + 16,
        left: 20,
        right: 20,
        child: _TopSnackBarWidget(
          message: message,
          isError: isError,
          onDismiss: () => dismissCustomSnackBar(),
        ),
      );
    },
  );

  overlayState.insert(_currentOverlayEntry!);

  // Auto dismiss after the specified duration
  _autoDismissTimer = Timer(duration, () {
    dismissCustomSnackBar();
  });
}

void dismissCustomSnackBar() {
  _autoDismissTimer?.cancel();
  _autoDismissTimer = null;

  if (_currentOverlayEntry != null) {
    try {
      _currentOverlayEntry!.remove();
    } catch (_) {}
    _currentOverlayEntry = null;
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _TopSnackBarWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _yAnimation = Tween<double>(begin: -150, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.isError
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFFCC18CA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.isError
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Message Text
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Close Button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleClose,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
