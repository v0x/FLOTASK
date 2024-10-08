import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF8D6E63), // Matching the app color scheme
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSettingsItem(
            title: 'Account',
            icon: Icons.person_outline,
            onTap: () => print('Account clicked'),
          ),
          buildSettingsItem(
            title: 'App Preferences',
            icon: Icons.tune,
            onTap: () => print('App Preferences clicked'),
          ),
          buildSettingsItem(
            title: 'About App',
            icon: Icons.info_outline,
            onTap: () => print('About App clicked'),
          ),
          const Divider(),
          buildSettingsItem(
            title: 'Notification Settings',
            icon: Icons.notifications,
            onTap: () => print('Notification Settings clicked'),
          ),
        ],
      ),
    );
  }

  // Reusable widget for settings items with a consistent color scheme and style
  Widget buildSettingsItem({required String title, required IconData icon, required VoidCallback onTap}) {
    final color = const Color(0xFFBCAAA4); // Light brown consistent with theme
    return Material(
      color: Colors.transparent, // Keeps background consistent
      child: ListTile(
        leading: Icon(icon, size: 28, color: color), // Matching icon style
        title: Text(
          title,
          style: TextStyle(fontSize: 16, color: color), // Matching text style
        ),
        onTap: onTap, // Executes action when tapped
      ),
    );
  }
}
