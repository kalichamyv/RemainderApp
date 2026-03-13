import 'package:flutter/material.dart';

class CustomTextfields extends StatelessWidget {
  final TextEditingController Controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardtype;
  final int maxLines;

  const CustomTextfields({
    required this.Controller,
    required this.hint,
    required this.icon,
    required this.keyboardtype,
    required this.label,
    required this.maxLines,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: Controller,
        keyboardType: keyboardtype,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        maxLines: maxLines,
      ),
    );
  }
}
