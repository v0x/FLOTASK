import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({
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
            'Progress Page',
          ),
        ),
      ),
    );
  }
}
