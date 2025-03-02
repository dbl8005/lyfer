import 'package:flutter/material.dart';

class AuthButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;
  const AuthButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
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
      ),
      child: widget.isLoading
          ? const CircularProgressIndicator()
          : Text(widget.text, style: TextStyle(fontSize: 16)),
    );
  }
}
