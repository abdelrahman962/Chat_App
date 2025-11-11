import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final double height;
  final RegExp validation;
  final bool obscureText;
  final void Function(String?) onSaved;
  const CustomField({
    super.key,
    required this.hintText,
    required this.height,
    required this.validation,
    this.obscureText = false,
    required this.onSaved,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        obscureText: obscureText,
        validator: (value) {
          if (value != null && validation.hasMatch(value)) {
            return null;
          }
          return "Enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        onSaved: onSaved,
      ),
    );
  }
}
