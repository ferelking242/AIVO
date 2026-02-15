import 'package:flutter/material.dart';

class AppToast {
  /// Show success toast
  static void success(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green);
  }

  /// Show error toast
  static void error(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red);
  }

  /// Show info toast
  static void info(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue);
  }

  /// Show warning toast
  static void warning(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange);
  }

  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show custom toast
  static void custom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    TextStyle? textStyle,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textStyle ?? const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
