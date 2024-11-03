import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  final DateTime goalStartDate; //WR3(
  final DateTime goalEndDate;

  AddTaskPage({required this.goalStartDate, required this.goalEndDate}); //WR3)

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskController =
      TextEditingController(); // Controller for task name
  final ValueNotifier<int> _repeatIntervalNotifier =
      ValueNotifier<int>(1); // ValueNotifier to manage repeat interval

  DateTime? _startDate; // Variable to store start date
  DateTime? _endDate; // Variable to store end date
  TimeOfDay? _selectedTime; // Variable to store the selected time
  String _selectedOption = 'Any time'; // Default option

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

  @override
  void dispose() {
    _taskController.dispose(); // Dispose controller to avoid memory leaks
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task Name Input
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
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
                      child: Text(value), // Display text for each option
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

            // Add Task Button
            ElevatedButton(
              onPressed: () {
                final taskData = {
                  'task': _taskController.text,
                  'repeatInterval': _repeatIntervalNotifier.value,
                  'startDate': _startDate,
                  'endDate': _endDate,
                  'selectedTime': _selectedTime?.format(context),
                };

                //final task = _taskController.text;
                // if (task.isNotEmpty) {
                //   Navigator.pop(
                //       context, task); // Return the task to the AddGoalPage
                // }
                if (taskData['task'].toString().isNotEmpty) {
                  Navigator.pop(context, taskData);
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
