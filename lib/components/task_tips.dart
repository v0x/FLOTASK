import 'package:flutter/material.dart';

class TaskTipsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Task Management Tips'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown.shade700),
        titleTextStyle: TextStyle(
          color: Colors.brown.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Effective Task Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Here are some tips for managing your tasks efficiently:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade600,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTipItem('Break down large tasks into smaller steps.'),
                    _buildTipItem('Prioritize tasks by importance.'),
                    _buildTipItem('Set clear deadlines and stick to them.'),
                    _buildTipItem('Use a task management tool like FloTask to track progress.'),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'More tips coming soon...',
                  style: TextStyle(
                    color: Colors.brown.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each task tip item
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.brown.shade700),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
