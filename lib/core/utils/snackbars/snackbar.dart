import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

class AppSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.fixed,
    EdgeInsetsGeometry? margin,
    Widget? sideIcon,
  }) {
    final snackBar = SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Row(children: [
        sideIcon ?? const SizedBox.shrink(),
        const SizedBox(width: 8),
        Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ]),
      duration: duration,
      backgroundColor: backgroundColor,
      action: action,
      behavior: behavior,
      margin: margin,
      dismissDirection: DismissDirection.horizontal,
    );

    // Hide current snackbar (if any) before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      textColor: Colors.white,
      duration: duration,
      action: action,
      sideIcon: LineIcon.check(
        color: Colors.white,
        size: 20,
      ),
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      textColor: Colors.white,
      duration: duration,
      action: action,
      sideIcon: LineIcon.times(
        color: Colors.white,
        size: 20,
      ),
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }
}
