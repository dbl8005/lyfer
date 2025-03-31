import 'package:flutter/material.dart';
import 'package:lyfer/core/utils/validators/password_validator.dart';
import 'package:lyfer/features/auth/constants/auth_constants.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;

  const PasswordFormField({
    super.key,
    required this.controller,
    required this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: AuthConstants.passwordLabel,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon:
              Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      obscureText: _obscurePassword,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
    );
  }
}
