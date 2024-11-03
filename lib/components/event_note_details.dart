import 'package:flotask/models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';
import 'package:flotask/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flotask/components/voice_memos.dart';

// widget to show event details and markdown note section
class EventDetailWithNotes extends StatefulWidget {
  // variable passed down from constructor
  final EventModel? event;

  EventDetailWithNotes({this.event});

  @override
  _EventDetailWithNotesState createState() => _EventDetailWithNotesState();
}

class _EventDetailWithNotesState extends State<EventDetailWithNotes> {
  TextEditingController _noteController = TextEditingController();

// way to initialize an event and set it to the GLOBAL event provider
  late EventModel event;
  @override
  void initState() {
    super.initState();
    event = widget.event!;
    _noteController.text = event.note ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(event.event.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Text(
                'Start Time: ${DateFormat('h:mm a').format(event.event.startTime!)}'),
            Text(
                'End Time: ${DateFormat('h:mm a').format(event.event.endTime!)}'),
            Text(
                'Start Date: ${DateFormat('MM-dd-yyy').format(event.event.date)}'),
            Text(
                'End Date: ${DateFormat('MM-dd-yyyy').format(event.event.endDate!)}'),
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
                  hintText: event.note,
                ),
              ),
            ),
            Center(
              child: VoiceMemo(
                event: event,
              ),
            ),
            ElevatedButton(
              // update event global provider to update note
              onPressed: () {
                setState(() {
                  context
                      .read<EventProvider>()
                      .updateNote(event.id!, _noteController.text);

                  Navigator.pop(context);
                });
              },
              child: Text("Save Note"),
            ),
          ],
        ));
  }
}
