import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(8.0),
      child: SizedBox.expand(
        child: Center(
          child: Text(
            'Calendar Page',
          ),
        ),
      ),
    );
  }
}
