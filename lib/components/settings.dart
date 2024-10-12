import 'package:flutter/material.dart';

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
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'Your App Name',
                          applicationVersion: '1.0.0',
                          applicationIcon: Icon(Icons.info_outline),
                          children: [Text("This is a sample app to showcase settings functionality.")],
                        ),
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

// App Preferences Page for settings like font size and language
class AppPreferencesPage extends StatefulWidget {
  @override
  _AppPreferencesPageState createState() => _AppPreferencesPageState();
}

class _AppPreferencesPageState extends State<AppPreferencesPage> {
  String _selectedFontSize = 'Medium';
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('App Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Font Size Selection
          ListTile(
            leading: Icon(Icons.text_fields, color: Color(0xFF8D6E63)),
            title: Text('Font Size'),
            trailing: DropdownButton<String>(
              value: _selectedFontSize,
              items: ['Small', 'Medium', 'Large'].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedFontSize = newValue!),
            ),
          ),
          const Divider(),
          // Language Selection
          ListTile(
            leading: Icon(Icons.language, color: Color(0xFF8D6E63)),
            title: Text('App Language'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: ['English', 'Spanish', 'French'].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedLanguage = newValue!),
            ),
          ),
        ],
      ),
    );
  }
}

// Notification Settings Page for managing notifications
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
      appBar: AppBar(title: Text('Notification Settings')),
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
            ),
          ),
        ],
      ),
    );
  }
}
