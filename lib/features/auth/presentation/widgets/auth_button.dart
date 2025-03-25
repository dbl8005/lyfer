import 'package:flutter/material.dart';
import 'package:lyfer/core/constants/ui_constants.dart';

class AuthButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;
  final Color? buttonColor;
  final Icon? leadingIcon;

  const AuthButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
    this.buttonColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(vertical: UIConstants.mediumSpacing),
        backgroundColor: buttonColor,
        fixedSize: UIConstants.defaultButtonSize,
      ),
      child: isLoading
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
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  const SizedBox(width: UIConstants.smallSpacing),
                ],
                Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
    );
  }
}
