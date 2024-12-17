import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart'; // For input formatters

class AddTaskPage extends StatefulWidget {
  final DateTime goalStartDate; // WR3(
  final DateTime goalEndDate;

  AddTaskPage({required this.goalStartDate, required this.goalEndDate}); // WR3)

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskController =
      TextEditingController(); // Controller for task name
  final TextEditingController _workTimeController =
      TextEditingController(); // Controller for work time
  final TextEditingController _breakTimeController =
      TextEditingController(); // Controller for break time
  final ValueNotifier<int> _repeatIntervalNotifier =
      ValueNotifier<int>(1); // ValueNotifier to manage repeat interval

  DateTime? _startDate; // Variable to store start date
  DateTime? _endDate; // Variable to store end date
  TimeOfDay? _selectedTime; // Variable to store the selected time
  String _selectedOption = 'Any time'; // Default option
  Color _selectedColor = Colors.blue; // Default color

  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      ValueChanged<DateTime?> onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          initialDate ?? DateTime.now(), // Set initial date to current if null
      firstDate: widget
          .goalStartDate, // Ensure task start date is not earlier than goal start date //WR3(
      lastDate: widget
          .goalEndDate, // Ensure task end date is not later than goal end date //WR3)
    );
    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate); // Update the selected date
    }
  }

  // Function to select a specific time using a time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Set the default time
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked; // Set the selected time
        _selectedOption = 'Specific time'; // Update option if a time is picked
      });
    }
  }

  // Method to open color picker dialog
  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const Text('Select Task Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                setState(() {
                  _selectedColor = tempColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _taskController.dispose(); // Dispose controller to avoid memory leaks
    _workTimeController.dispose(); // Dispose work time controller
    _breakTimeController.dispose(); // Dispose break time controller
    _repeatIntervalNotifier.dispose(); // Dispose notifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        backgroundColor: const Color(0xFFEBEAE3),
      ),
      backgroundColor: const Color(0xFFEBEAE3),
      body: SingleChildScrollView( // To prevent overflow when keyboard appears
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Task Name Input
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  prefixIcon: Icon(Icons.task),
                ),
              ),

              const SizedBox(height: 16.0),

              // Row for Date Selection
              Row(
                children: [
                  // Button to select start date
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, _startDate, (date) {
                        setState(() {
                          _startDate = date; // Set selected start date
                        });
                      }),
                      child: Text(_startDate == null
                          ? 'Select Start Date'
                          : 'Start Date: ${_startDate!.year}-${_startDate!.month}-${_startDate!.day}'),
                    ),
                  ),
                  const SizedBox(
                      width: 16.0), // Space between start and end date buttons
                  // Button to select end date
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, _endDate, (date) {
                        setState(() {
                          _endDate = date; // Set selected end date
                        });
                      }),
                      child: Text(_endDate == null
                          ? 'Select End Date'
                          : 'End Date: ${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'), // Properly formatted date
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // Dropdown for Selecting Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Time:'),
                  DropdownButton<String>(
                    value: _selectedOption,
                    items:
                        <String>['Any time', 'Specific time'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value, // Value for each option
                        child: Text(value, style: TextStyle(color: Colors.black),), // Display text for each option
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!; // Update the selected option
                        if (newValue == 'Specific time') {
                          _selectTime(
                              context); // Open time picker if "Specific time" is selected
                        } else {
                          _selectedTime = null; // Reset the selected time
                        }
                      });
                    },
                  ),
                ],
              ),

              // Display the selected time if "Specific time" is chosen
              if (_selectedOption == 'Specific time' && _selectedTime != null)
                Text('Selected Time: ${_selectedTime!.format(context)}'),

              const SizedBox(height: 16.0),

              // Repeat Every Section
              const Text(
                'Repeat Every',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8.0),

              // Row to Adjust Repeat Interval
              Row(
                children: [
                  // Button to decrease repeat interval
                  IconButton(
                    icon: const Icon(Icons.remove), // Minus icon
                    onPressed: () {
                      if (_repeatIntervalNotifier.value > 1) {
                        _repeatIntervalNotifier
                            .value--; // Decrease interval if greater than 1
                      }
                    },
                  ),
                  // Display the current repeat interval
                  ValueListenableBuilder<int>(
                    valueListenable:
                        _repeatIntervalNotifier, // Listen to changes in interval
                    builder: (context, value, child) {
                      return Text(
                        ' $value days', // Show the interval in days
                        style: const TextStyle(fontSize: 16),
                      );
                    },
                  ),
                  // Button to increase repeat interval
                  IconButton(
                    icon: const Icon(Icons.add), // Plus icon
                    onPressed: () {
                      _repeatIntervalNotifier.value++; // Increase interval by 1
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Work Time Input
              TextField(
                controller: _workTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Work Time (minutes)',
                  hintText: 'Enter work duration in minutes',
                  prefixIcon: Icon(Icons.timer),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
              ),

              const SizedBox(height: 16.0),

              // Break Time Input
              TextField(
                controller: _breakTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Break Time (minutes)',
                  hintText: 'Enter break duration in minutes',
                  prefixIcon: Icon(Icons.pause_circle_filled),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
              ),

              const SizedBox(height: 16.0),

              // Color Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Color:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickColor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor, // Set the button color to the selected color
                        ),
                        child: const Text(
                          'Select Color',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Display selected color
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // Add Task Button
              ElevatedButton(
                onPressed: () {
                  // Input Validations
                  if (_taskController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a task name')),
                    );
                    return;
                  }

                  if (_startDate == null || _endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select start and end dates')),
                    );
                    return;
                  }

                  if (_startDate!.isAfter(_endDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Start date must be before end date')),
                    );
                    return;
                  }

                  int workTime = int.tryParse(_workTimeController.text) ?? 0;
                  int breakTime = int.tryParse(_breakTimeController.text) ?? 0;

                  if (workTime <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Work time must be greater than 0')),
                    );
                    return;
                  }

                  if (breakTime < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Break time cannot be negative')),
                    );
                    return;
                  }

                  final taskData = {
                    'task': _taskController.text,
                    'repeatInterval': _repeatIntervalNotifier.value,
                    'startDate': _startDate,
                    'endDate': _endDate,
                    'selectedTime': _selectedTime?.format(context),
                    'workTime': workTime,
                    'breakTime': breakTime,
                    'color': _selectedColor.value.toRadixString(16), // Store color as hex string
                  };

                  Navigator.pop(context, taskData);
                },
                child: const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
