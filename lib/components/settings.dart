import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8D6E63)),
                  ),
                ],
              ),
            ),
            // List of setting options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Account and App Preferences Section
                  buildSettingsSection(
                    items: [
                      buildSettingsItem(
                        title: 'Account',
                        icon: Icons.person_outline,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage())),
                      ),
                      buildSettingsItem(
                        title: 'App Preferences',
                        icon: Icons.tune,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppPreferencesPage())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // About App Section
                  buildSettingsSection(
                    items: [
                      buildSettingsItem(
                        title: 'About App',
                        icon: Icons.info_outline,
                        onTap: () => showAboutDialogModified(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Notification Settings Section
                  buildSettingsSection(
                    items: [
                      buildSettingsItem(
                        title: 'Notification Settings',
                        icon: Icons.notifications_outlined,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Creates a settings section with multiple options
  Widget buildSettingsSection({required List<Widget> items}) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      child: Column(children: items),
    );
  }

  // Creates a single settings item with icon and navigation
  Widget buildSettingsItem({required String title, required IconData icon, required VoidCallback onTap}) {
    final color = Color(0xFF8D6E63);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, color: color))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Account Page with options for changing email, password, and deleting the account
class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildAccountOption(title: 'Change Email', icon: Icons.email_outlined),
          buildAccountOption(title: 'Change Password', icon: Icons.lock_outline),
          const Divider(),
          buildAccountOption(title: 'Delete Account', icon: Icons.delete_outline, isDestructive: true),
        ],
      ),
    );
  }

  // Creates an option for the account settings
  Widget buildAccountOption({required String title, required IconData icon, bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : Color(0xFF8D6E63);
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, color: color))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// App Preferences Page with Feedback and Report Issue forms
class AppPreferencesPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Function to save feedback to Firestore
  Future<void> _saveFeedback(BuildContext context) async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a message.')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feedback submitted successfully!')));
      _emailController.clear();
      _messageController.clear();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit feedback. Please try again.')));
    }
  }

  // Function to save issues to Firestore
  Future<void> _saveIssue(BuildContext context) async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a message.')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Issue reported successfully!')));
      _emailController.clear();
      _messageController.clear();
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to report issue. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Send Feedback option
          ListTile(
            leading: Icon(Icons.feedback_outlined, color: Color(0xFF8D6E63)),
            title: Text('Send Feedback'),
            onTap: () => _showForm(context, 'Feedback', _saveFeedback),
          ),
          const Divider(),

          // Report Issue option
          ListTile(
            leading: Icon(Icons.bug_report_outlined, color: Color(0xFF8D6E63)),
            title: Text('Report Issue'),
            onTap: () => _showForm(context, 'Issue', _saveIssue),
          ),
        ],
      ),
    );
  }

  // Function to show form for feedback or reporting an issue
  void _showForm(BuildContext context, String type, Future<void> Function(BuildContext) saveFunction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Submit $type',
            style: TextStyle(color: Color(0xFF8D6E63), fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Your Email (optional)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8D6E63)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Your $type',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF8D6E63)),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8D6E63)),
              ),
              onPressed: () {
                _emailController.clear();
                _messageController.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.black), // Submit button text is black
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8D6E63), // Matches app theme
              ),
              onPressed: () => saveFunction(context),
            ),
          ],
        );
      },
    );
  }
}

// About App dialog modification
void showAboutDialogModified(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.task, color: Color(0xFF8D6E63), size: 40),
            const SizedBox(width: 8),
            Text(
              'FloTask',
              style: TextStyle(color: Color(0xFF8D6E63), fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "FloTask is a task management app designed to help you organize your goals and track progress effectively.",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            child: Text(
              'View Licenses',
              style: TextStyle(color: Colors.black), // Black text
            ),
            onPressed: () {
              showLicensePage(context: context, applicationName: 'FloTask');
            },
          ),
          TextButton(
            child: Text(
              'Close',
              style: TextStyle(color: Colors.black), // Black text
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

// Notification Settings Page
class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationsEnabled = true;
  bool _notificationSoundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
        backgroundColor: Colors.transparent, // Default or transparent AppBar color
        elevation: 0, // Flat AppBar
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Toggle for enabling notifications
          ListTile(
            leading: Icon(Icons.notifications, color: Color(0xFF8D6E63)),
            title: Text('Enable Notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
              activeColor: Color(0xFF8D6E63), // Brown for the toggle circle (thumb)
              activeTrackColor: Colors.grey.shade300, // Neutral gray for the track
              inactiveThumbColor: Colors.grey, // Gray circle (thumb) when inactive
              inactiveTrackColor: Colors.grey.shade300, // Neutral gray for the track when inactive
            ),
          ),
          const Divider(),
          // Toggle for enabling notification sounds
          ListTile(
            leading: Icon(Icons.volume_up, color: Color(0xFF8D6E63)),
            title: Text('Notification Sound'),
            trailing: Switch(
              value: _notificationSoundEnabled,
              onChanged: (value) => setState(() => _notificationSoundEnabled = value),
              activeColor: Color(0xFF8D6E63), // Brown for the toggle circle (thumb)
              activeTrackColor: Colors.grey.shade300, // Neutral gray for the track
              inactiveThumbColor: Colors.grey, // Gray circle (thumb) when inactive
              inactiveTrackColor: Colors.grey.shade300, // Neutral gray for the track when inactive
            ),
          ),
        ],
      ),
    );
  }
}
