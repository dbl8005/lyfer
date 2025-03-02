import 'package:flutter/material.dart';

/// A dialog that displays an error message to the user.
class ErrorDialog extends StatelessWidget {
  /// The title of the error dialog.
  final String title;

  /// The error message to display.
  final String message;

  /// Optional callback when the dialog is dismissed.
  final VoidCallback? onDismiss;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.onDismiss,
  }) : super(key: key);

  /// Shows the error dialog.
  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          message: message,
          onDismiss: onDismiss,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(message),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
