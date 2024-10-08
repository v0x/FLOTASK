import 'package:flutter/material.dart';
import 'package:flotask/components/resource.dart';
import 'package:flotask/components/settings.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final safeArea = EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);

    return Container(
      width: MediaQuery.of(context).size.width * 0.6, // Sidebar width set to 60% of screen
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // Transparent off-white background
          ),
          child: Column(
            children: [
              // Sidebar header with padding, always visible
              Container(
                padding: EdgeInsets.symmetric(vertical: 24).add(safeArea),
                width: double.infinity,
                child: buildHeader(),
              ),
              const Divider(), // Divider line below header
              // Menu items below the header, using a ListView for scrollable content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    buildMenuItem(
                      icon: Icons.share,
                      title: 'Share',
                      onTap: () => print('Share clicked'),
                    ),
                    buildMenuItem(
                      icon: Icons.book,
                      title: 'Resources',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResourcesPage()), // Navigating to ResourcePage
                      ),
                    ),
                    buildMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()), // Navigating to SettingsPage
                      ),
                    ),
                    buildMenuItem(
                      icon: Icons.exit_to_app,
                      title: 'Log Out',
                      onTap: () => print('Log Out clicked'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the header for the menu
  Widget buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: Text(
        'FloTask',
        style: TextStyle(fontSize: 24, color: Color(0xFF8D6E63)), // Using color directly for consistency
      ),
    );
  }

  // Builds individual menu items with icon and label
  Widget buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    final color = const Color(0xFFBCAAA4); // Light brown consistent with theme
    return Material(
      color: Colors.transparent, // Keeps the menu background transparent
      child: ListTile(
        leading: Icon(icon, size: 28, color: color), // Icon with adjusted size
        title: Text(
          title,
          style: TextStyle(fontSize: 16, color: color), // Simple, clean font styling
        ),
        onTap: onTap, // Executes action when menu item is tapped
      ),
    );
  }
}
