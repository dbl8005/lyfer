import 'package:flutter/material.dart';
import 'package:lyfer/core/utils/validators/email_validator.dart';
import 'package:lyfer/features/auth/constants/auth_constants.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const EmailFormField({
    super.key,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: AuthConstants.emailLabel,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      autocorrect: false,
      textInputAction: TextInputAction.next,
    );
  }
}
