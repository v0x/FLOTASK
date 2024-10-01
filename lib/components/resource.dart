import 'package:flutter/material.dart';

class ResourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resources'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search resources...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20), // Add space between the search bar and description
            // About App Description
            Text(
              'Welcome to the Resources page. Here you can find useful information and links related to the app. Use the search bar to quickly find specific resources.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20), // Add space before the list
            // Placeholder List
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Resource 1'),
                    subtitle: Text('Description of Resource 1'),
                    onTap: () {
                      // Add your navigation or action here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.link),
                    title: Text('Resource 2'),
                    subtitle: Text('Description of Resource 2'),
                    onTap: () {
                      // Add your navigation or action here
                    },
                  ),
                  // Add more resources as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
