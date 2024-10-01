import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/components/textfield.dart';
import 'package:flotask/models/event_model.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Widget to show a dialog, where the user can input event, title, start time, end time, description, start date, and end date
class EventDialog extends StatefulWidget {
  final EventController eventController;
  final DateTime? longPressDate;
  final DateTime? longPressEndDate;
  const EventDialog(
      {required this.eventController,
      this.longPressDate,
      this.longPressEndDate,
      super.key});

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
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

  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();

    // Set the initial start date if provided
    if (widget.longPressDate != null) {
      _startDate = widget.longPressDate!;
      _startDateController.text =
          DateFormat.yMMMd().format(widget.longPressDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.read<EventProvider>();

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CheckboxListTile(
                title: Text("Is this a recurring task?"),
                value: _isRecurring,
                onChanged: (bool? value) {
                  setState(() {
                    _isRecurring = value ?? false;
                  });
                },
              ),
            ),
            TextButton(

                // main functionality to add an event to global EventModel class
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
                    ),
                  );

                  widget.eventController.add(event);

                  eventProvider.addEvent(event,
                      note: "Some notes",
                      tags: ["work"],
                      isRecurring: _isRecurring);
                  print(eventProvider);
                  Navigator.of(context).pop();
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }

// function to show the TIME PICKER
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

// function to show the DATE PICKER
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
