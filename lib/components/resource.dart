import 'package:flutter/material.dart';

class ResourcesPage extends StatefulWidget {
  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  // List of resources containing title, description, and URL
  final List<Map<String, String>> _resources = [
    {
      'title': 'Task Management Tips',
      'description': 'Learn how to manage tasks efficiently.',
      'url': 'https://example.com/task-management-tips',
    },
    {
      'title': 'App User Manual',
      'description': 'A guide on how to use FloTask efficiently.',
      'url': 'https://example.com/user-manual',
    },
    {
      'title': 'Pomodoro Technique',
      'description': 'Learn about the Pomodoro method for productivity.',
      'url': 'https://example.com/pomodoro',
    },
    {
      'title': 'Frequently Asked Questions',
      'description': 'Common questions about the FloTask app.',
      'url': 'https://example.com/faq',
    },
    {
      'title': 'Support & Help',
      'description': 'Get in touch with our support team.',
      'url': 'https://example.com/support',
    },
  ];

  String _searchQuery = ''; // Search query for filtering resources

  @override
  Widget build(BuildContext context) {
    // Filters the list of resources based on the search query
    final filteredResources = _resources
        .where((resource) =>
            resource['title']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Resources', style: TextStyle(color: Colors.brown.shade700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown.shade700),
          onPressed: () => Navigator.pop(context), // Navigate back
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.brown.shade700),
            onPressed: _openSupport, // Open support functionality
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildListView(filteredResources), // Build list of resources
      ),
    );
  }

  // Builds a list view of filtered resources
  Widget _buildListView(List<Map<String, String>> resources) {
    return ListView.builder(
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(
              resource['title']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),
            subtitle: Text(
              resource['description']!,
              style: TextStyle(color: Colors.brown.shade300),
            ),
            leading: Icon(Icons.link, color: Colors.brown.shade700),
            onTap: () => _openResourcePage(context, resource), // Navigate to detailed page
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          ),
        );
      },
    );
  }

  // Navigates to the detailed resource page with a slide transition
  void _openResourcePage(BuildContext context, Map<String, String> resource) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ResourceDetailPage(resource: resource);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide animation from right to left
          return SlideTransition(
            position: Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.ease))
                .animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  // Placeholder for opening support, can be expanded to a form or chat
  void _openSupport() {
    print('Opening support');
  }
}

class ResourceDetailPage extends StatelessWidget {
  final Map<String, String> resource;

  ResourceDetailPage({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource['description']!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Open the URL in a browser or web view
                print('Opening resource: ${resource['url']}');
              },
              child: Text('Open Resource'),
            ),
          ],
        ),
      ),
    );
  }
}
