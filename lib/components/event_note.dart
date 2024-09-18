import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class EventDetailWithNotes extends StatefulWidget {
  @override
  _EventDetailWithNotesState createState() => _EventDetailWithNotesState();
}

class _EventDetailWithNotesState extends State<EventDetailWithNotes> {
  bool showNotes =
      false; // State variable to control the visibility of the notes section
  TextEditingController _noteController = TextEditingController();
  String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MarkdownAutoPreview(
              controller: _noteController,
              emojiConvert: true,
              enableToolBar: true,
              toolbarBackground: Colors.blue,
              expandableBackground: Colors.blue[200],
              maxLines: 9,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              note = _noteController.text; // Save the note content
            });
          },
          child: Text("Save Note"),
        ),
        if (showNotes) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "Enter your note",
                border: OutlineInputBorder(),
              ),
              maxLines: 9,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                note = _noteController.text; // Save the note
                showNotes = false; // Hide the note section after saving
              });
            },
            child: Text("Save Note"),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Note: $note",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      ],
    );
  }
}
