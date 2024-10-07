import 'package:flutter/material.dart';
import 'task_tips.dart';
import 'manual.dart';
import 'pomodoro_tips.dart';
import 'faq.dart';
import 'support.dart';

class ResourcesPage extends StatefulWidget {
  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final List<Map<String, String>> _resources = [
    {'title': 'Task Management Tips', 'description': 'Learn how to manage tasks efficiently.'},
    {'title': 'App User Manual', 'description': 'A guide on how to use FloTask efficiently.'},
    {'title': 'Pomodoro Technique', 'description': 'Learn about the Pomodoro method for productivity.'},
    {'title': 'Frequently Asked Questions', 'description': 'Common questions about the FloTask app.'},
    {'title': 'Support & Help', 'description': 'Get in touch with our support team.'},
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredResources = _resources.where((resource) => resource['title']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Resources', style: TextStyle(color: Colors.brown.shade700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.brown.shade700),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredResources.length,
          itemBuilder: (context, index) {
            final resource = filteredResources[index];
            return ListTile(
              title: Text(resource['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade700)),
              subtitle: Text(resource['description']!, style: TextStyle(color: Colors.brown.shade300)),
              leading: Icon(Icons.link, color: Colors.brown.shade700),
              onTap: () => _openResourcePage(resource['title']!),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            );
          },
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Need Help?'),
          content: Text('For assistance, please check out the Support & Help section or contact our team.'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _openResourcePage(String title) {
    Widget page;
    switch (title) {
      case 'Task Management Tips':
        page = TaskTipsPage();
        break;
      case 'App User Manual':
        page = ManualPage();
        break;
      case 'Pomodoro Technique':
        page = PomodoroPage();
        break;
      case 'Frequently Asked Questions':
        page = FaqPage();
        break;
      case 'Support & Help':
        page = SupportPage();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.ease))),
            child: child,
          );
        },
      ),
    );
  }
}
