import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/models/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

class EventDialog extends StatefulWidget {
  const EventDialog({super.key});

  @override
  State<EventDialog> createState() => _EventDialogState();
}

// TODO: figure out how to add events either through floating action button or onTap of event

class _EventDialogState extends State<EventDialog> {
  EventController _controller = EventController();
  TextEditingController _eventController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Event'),
      scrollable: true,
      content: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: TextInput(
                controller: _eventController,
                label: 'Event',
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: TextInput(controller: _titleController, label: "Title"),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextInput(
                      controller: _startDateController,
                      label: 'Start Date',
                      onTap: () {
                        _selectDate(context, true);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextInput(
                      controller: _endDateController,
                      label: 'End Date',
                      onTap: () {
                        _selectDate(context, false);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextInput(
                      controller: _startTimeController,
                      label: 'Start Time',
                      onTap: () {
                        _selectTime(context, true);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextInput(
                      controller: _endTimeController,
                      label: 'End Time',
                      onTap: () {
                        _selectTime(context, false);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: TextInput(
                controller: _descController,
                label: 'Description',
                line: 7,
              ),
            ),
            TextButton(
                onPressed: () {
                  final event = CalendarEventData(
                      title: _titleController.text,
                      date: _startDate,
                      endDate: _endDate,
                      description: _descController.text,
                      startTime: DateTime(_startDate.year, _startDate.month,
                          _startDate.day, _startTime.hour, _startTime.minute),
                      endTime: DateTime(
                        _endDate.year,
                        _endDate.month,
                        _endDate.day,
                        _endTime.hour,
                        _endTime.minute,
                      ));

                  CalendarControllerProvider.of(context).controller.add(event);
                  Navigator.of(context).pop();
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }

  Future _selectTime(BuildContext context, bool time) async {
    final setTime = time ? _startTime : _endTime;
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: setTime);

    if (pickedTime != null && pickedTime != setTime) {
      setState(() {
        if (time) {
          _startTime = pickedTime;
          _startTimeController.text = pickedTime.format(context).toString();
        } else {
          _endTime = pickedTime;
          _endTimeController.text = pickedTime.format(context).toString();
        }
      });
    }
  }

  Future _selectDate(BuildContext context, bool date) async {
    final setDate = date ? _startDate : _endDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != setDate) {
      setState(() {
        if (date) {
          _startDate = pickedDate;
          _startDateController.text = DateFormat.yMMMd().format(pickedDate);
        } else {
          _endDate = pickedDate;
          _endDateController.text = DateFormat.yMMMd().format(pickedDate);
        }
      });
    }
  }
}
