import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Entire menu is white
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('John Doe', style: TextStyle(color: Colors.black)),
              accountEmail: Text('example@gmail.com', style: TextStyle(color: Colors.black)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white, // White background for the profile icon
                child: Icon(Icons.person, size: 40, color: Colors.black), // Icon in black
              ),
              decoration: BoxDecoration(
                color: Colors.white, // White background for the user area
                boxShadow: [ // Adding shadow for depth
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            _buildMenuItem(Icons.share, 'Share'),
            _buildDivider(), // Adding line separator
            _buildMenuItem(Icons.book, 'Resources'),
            _buildDivider(),
            _buildMenuItem(Icons.settings, 'Settings'),
            _buildDivider(),
            _buildMenuItem(Icons.exit_to_app, 'Log Out'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.black)),
      onTap: () => null,
    );
  }

  Widget _buildDivider() {
    return Divider(
      thickness: 1,
      color: Colors.grey[300], // Light grey line separator
    );
  }
}
