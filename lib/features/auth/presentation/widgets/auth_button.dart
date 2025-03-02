import 'package:flutter/material.dart';

class AuthButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color? buttonColor; // Optional button color
  final Icon? leadingIcon; // Optional leading icon

  const AuthButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.buttonColor, // Optional parameter
    this.leadingIcon, // Optional parameter
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: widget.buttonColor,
        fixedSize: Size(200, 60),
      ),
      child: widget.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leadingIcon != null) ...[
                  widget.leadingIcon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
    );
  }
}
