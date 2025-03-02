import 'package:flutter/material.dart';
import 'package:lyfer/core/utils/validators/email_validator.dart';

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
        labelText: 'Email',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: validator,
    );
  }
}
