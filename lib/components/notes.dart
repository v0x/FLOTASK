import 'package:flutter/material.dart';

class NotesWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const NotesWidget({
    Key? key,
    required this.controller,
    this.hintText = "Enter your notes here...",
  }) : super(key: key);

  @override
  _NotesWidgetState createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200,
      ),
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
