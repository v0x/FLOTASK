import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('App User Manual'),
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
                'This user manual will guide you through all the features of FloTask. '
                'You will learn how to create, edit, and manage tasks effectively. '
                'Additionally, the manual covers advanced settings, including reminders, task priorities, and more.',
              ),
              SizedBox(height: 24),
              _buildSectionTitle('How to Use FloTask'),
              _buildBulletPoint('- Create a task by tapping the "+" button at the bottom right.'),
              _buildBulletPoint('- Edit tasks by selecting the task from the list and modifying details.'),
              _buildBulletPoint('- Mark tasks as completed by checking them off.'),
              _buildBulletPoint('- Access settings to customize your task priorities and notifications.'),
              SizedBox(height: 24),
              _buildSectionTitle('Advanced Features'),
              _buildBulletPoint('- Set reminders for tasks based on deadlines.'),
              _buildBulletPoint('- Prioritize tasks with high importance to keep on top of your goals.'),
              _buildBulletPoint('- Sync tasks across multiple devices to ensure you never miss a deadline.'),
              SizedBox(height: 24),
              _buildSectionTitle('Terms of Use'),
              _buildContentText(
                'By using FloTask, you agree to our Terms of Use. This includes adhering to all the policies set forth '
                'regarding data privacy, task management, and user behavior within the app. Any misuse of the app may result '
                'in temporary or permanent suspension of your account. For more information, visit our Terms and Conditions page.',
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'More features and details coming soon...',
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
