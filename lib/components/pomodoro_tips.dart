import 'package:flutter/material.dart';

class PomodoroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Pomodoro Technique'),
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
              _buildSectionTitle('Introduction'),
              _buildContentText(
                'The Pomodoro Technique is a time management method that encourages working in short, focused bursts followed by breaks. '
                'This helps maintain high levels of productivity while avoiding burnout.'
              ),
              SizedBox(height: 24),
              _buildSectionTitle('How It Works'),
              _buildBulletPoint('- Work for 25 minutes (called a “Pomodoro”).'),
              _buildBulletPoint('- Take a 5-minute break after each Pomodoro.'),
              _buildBulletPoint('- After four Pomodoros, take a longer break (15-30 minutes).'),
              SizedBox(height: 24),
              _buildSectionTitle('Why It Works'),
              _buildContentText(
                'The Pomodoro Technique is effective because it promotes sustained focus on a task without distractions, while the scheduled '
                'breaks help recharge your mind. This method prevents mental fatigue and keeps you motivated throughout the day.'
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Benefits'),
              _buildBulletPoint('- Improves concentration and focus.'),
              _buildBulletPoint('- Reduces procrastination by breaking work into manageable intervals.'),
              _buildBulletPoint('- Helps balance work and rest for better overall productivity.'),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'More productivity tips coming soon...',
                  style: TextStyle(
                    color: Colors.brown.shade600,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade700,
      ),
    );
  }

  // Helper method to build content text
  Widget _buildContentText(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.brown.shade600,
        height: 1.5, // Line height for better readability
      ),
    );
  }

  // Helper method to build bullet points
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.brown.shade700),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
