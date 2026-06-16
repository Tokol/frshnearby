import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
