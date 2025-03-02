import 'package:flutter/material.dart';
import 'package:lyfer/core/utils/validators/password_validator.dart';

class ConfirmPasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;

  const ConfirmPasswordFormField({
    super.key,
    required this.controller,
    required this.passwordController,
  });

  @override
  State<ConfirmPasswordFormField> createState() =>
      _ConfirmPasswordFormFieldState();
}

class _ConfirmPasswordFormFieldState extends State<ConfirmPasswordFormField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Password',
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
      validator: (value) {
        return PasswordValidator.validateMatch(
          widget.passwordController.text,
          value,
        );
      },
    );
  }
}
