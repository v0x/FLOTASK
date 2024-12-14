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
  late EventModel event;

  @override
  void initState() {
    super.initState();
    event = widget.event!;
    _noteController.text = event.note ?? '';
  }

  @override
  void dispose() {
    if (_noteController.text != event.note) {
      final eventProvider = context.read<EventProvider>();
      eventProvider.updateNote(event.id!, _noteController.text);
      event.note = _noteController.text;
    }
    _noteController.dispose();
    super.dispose();
  }

  String _getStreakFlair(EventModel event) {
    if (event.yearStreak != null && event.yearStreak! > 0) {
      return '🏆';
    } else if (event.monthStreak != null && event.monthStreak! > 0) {
      return '🥈';
    } else if (event.dayStreak != null && event.dayStreak! > 0) {
      return '🥉';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEAE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBEAE3),
        elevation: 0,
        title: Text(
          event.event.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // show the event times
                          Icon(Icons.access_time, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('h:mm a').format(event.event.startTime!)} - ${DateFormat('h:mm a').format(event.event.endTime!)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // show the event dates
                          Icon(Icons.calendar_today, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('MMM dd, yyyy').format(event.event.date)} - ${DateFormat('MMM dd, yyyy').format(event.event.endDate!)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (event.isRecurring) ...[
                        const SizedBox(height: 8),
                        Row(
                          // show the recurring logo
                          children: [
                            Icon(Icons.repeat, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Text(
                                  _getStreakFlair(event),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Streak: ${event.dayStreak} days',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                if (event.monthStreak! > 0) ...[
                                  const Text(', '),
                                  Text(
                                    '${event.monthStreak} months',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                                if (event.yearStreak! > 0) ...[
                                  const Text(', '),
                                  Text(
                                    '${event.yearStreak} years',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // logic to save note and update to firebase
                          ElevatedButton.icon(
                            onPressed: () {
                              final eventProvider =
                                  context.read<EventProvider>();
                              eventProvider.updateNote(
                                  event.id!, _noteController.text);
                              event.note = _noteController.text;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Note saved')),
                              );
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEBEAE3),
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MarkdownAutoPreview(
                        controller: _noteController,
                        emojiConvert: true,
                        enableToolBar: true,
                        toolbarBackground: const Color(0xFFEBEAE3),
                        expandableBackground: Colors.white,
                        maxLines: 12,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voice Memos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      VoiceMemo(event: event),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
