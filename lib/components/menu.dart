import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data'; // Import for Uint8List

class Menu extends StatelessWidget {
  final ScreenshotController screenshotController; // Accept ScreenshotController as a parameter

  Menu({required this.screenshotController}); // Constructor to initialize screenshotController

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
                      onTap: () => _shareProgress(context), // Call the share function
                    ),
                    buildMenuItem(
                      icon: Icons.book,
                      title: 'Resources',
                      onTap: () => print('Resources clicked'),
                    ),
                    buildMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => print('Settings clicked'),
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
    final color = const Color(0xFF8D6E63); // Light brown consistent with theme
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

  // Function to capture and share progress
  void _shareProgress(BuildContext context) async {
    try {
      final image = await screenshotController.capture(); // Capture the screenshot
      if (image != null) {
        // Show the preview dialog with the captured image
        _showPreviewDialog(context, image);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture the flower animation. Please try again.')),
        );
      }
    } catch (e) {
      print('Error capturing or sharing progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing your progress. Please try again.')),
      );
    }
  }

  // Dialog to show the preview of the captured image
  void _showPreviewDialog(BuildContext context, Uint8List image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Text(
            'Share Your Garden',
            style: TextStyle(color: Colors.black.withOpacity(0.8)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.memory(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Here’s your garden progress! Share it with your friends!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withOpacity(0.7)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red.withOpacity(0.8)),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Proceed to share the image
                await Share.shareXFiles(
                  [XFile.fromData(image, name: 'garden.png')],
                  text: 'Check out my garden progress!',
                );
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Share',
                style: TextStyle(color: Colors.green.withOpacity(0.8)),
              ),
            ),
          ],
        );
      },
    );
  }
}
