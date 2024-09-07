import 'package:flutter/material.dart';

// TODO: move to components folder

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int line;
  final Function()? onTap;

// constructor object that takes in these parameters
  TextInput(
      {super.key,
      required this.controller,
      required this.label,
      this.line = 1,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: line,
      onTap: onTap,
      decoration: InputDecoration(
        label: Text(label),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
