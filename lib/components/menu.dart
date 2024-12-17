import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flotask/components/resource.dart';
import 'package:flotask/components/settings.dart';

class Menu extends StatelessWidget {
  final ScreenshotController screenshotController; // Accept ScreenshotController as a parameter
  final VoidCallback toggleTheme; // Add toggle function
  final bool isDarkMode; // Add theme mode state

  Menu({
    required this.screenshotController,
    required this.toggleTheme,
    required this.isDarkMode,
  });

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
                      onTap: () => _shareProgress(context),
                    ),
                    buildMenuItem(
                      context: context,
                      icon: Icons.book,
                      title: 'Resources',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResourcesPage()),
                      ),
                    ),
                    buildMenuItem(
                      context: context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      ),
                    ),
                    buildMenuItem(
                      context: context,
                      icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      title: isDarkMode ? 'Light Mode' : 'Dark Mode',
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

  Widget buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          size: 28,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: onTap,
      ),
    );
  }

  // Function to capture and share progress
  void _shareProgress(BuildContext context) async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        _showPreviewDialog(context, image);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture the screenshot. Please try again.')),
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
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red.withOpacity(0.8)),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Share.shareXFiles(
                  [XFile.fromData(image, name: 'garden.png')],
                  text: 'Check out my garden progress!',
                );
                Navigator.pop(context);
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