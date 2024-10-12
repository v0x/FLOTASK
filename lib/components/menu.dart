import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final VoidCallback toggleTheme; // Add toggle function
  final bool isDarkMode; // Add theme mode state

  Menu({required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final safeArea = EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top);

    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 24).add(safeArea),
                width: double.infinity,
                child: buildHeader(),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    buildMenuItem(
                      context: context,
                      icon: Icons.share,
                      title: 'Share',
                      onTap: () => print('Share clicked'),
                    ),
                    buildMenuItem(
                      context: context,
                      icon: Icons.book,
                      title: 'Resources',
                      onTap: () => print('Resources clicked'),
                    ),
                    buildMenuItem(
                      context: context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => print('Settings clicked'),
                    ),
                    buildMenuItem(
                      context: context,
                      icon: isDarkMode ? Icons.light_mode : Icons.dark_mode, 
                      title: isDarkMode ? 'Light Mode' : 'Dark Mode', // Toggle label
                      onTap: toggleTheme,
                    ),
                    buildMenuItem(
                      context: context,
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

  Widget buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: Text(
        'FloTask',
        style: TextStyle(fontSize: 24),
      ),
    );
  }

 Widget buildMenuItem({required BuildContext context, required IconData icon, required String title, required VoidCallback onTap}) {
  // Extract color from the bodyLarge TextStyle

  return Material(
    color: Colors.transparent,
    child: ListTile(
      leading: Icon(icon, size: 28, color: Theme.of(context).textTheme.bodyLarge!.color ?? Colors.black), // Apply color from the theme
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
    ),
  );
}
}
