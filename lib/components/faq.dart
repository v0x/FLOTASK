import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<Map<String, String>> _faqs = [
    {'question': 'How do I add a task?', 'answer': 'Tap the "+" button at the bottom right of the home page to add a new task.'},
    {'question': 'Can I set recurring tasks?', 'answer': 'Yes, you can set tasks to repeat daily, weekly, or monthly in the task settings.'},
    {'question': 'How do I enable notifications?', 'answer': 'Go to Settings > Notifications to enable or customize notifications.'},
    {'question': 'How do I delete a task?', 'answer': 'Swipe left on a task to delete it.'},
    {'question': 'Can I sync tasks across devices?', 'answer': 'Yes, by logging into the app on multiple devices, your tasks will sync automatically.'},
  ];

  String _searchQuery = ''; // Search query for filtering FAQs

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final queryLower = _searchQuery.toLowerCase();
      return faq['question']!.toLowerCase().contains(queryLower) ||
             faq['answer']!.toLowerCase().contains(queryLower);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Frequently Asked Questions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.brown.shade700),
        titleTextStyle: TextStyle(
          color: Colors.brown.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(), // Build the search bar
            SizedBox(height: 16),
            Expanded(
              child: filteredFaqs.isNotEmpty
                  ? _buildFaqList(filteredFaqs) // Build the list of FAQs
                  : _buildNoResultsFound(), // Display message if no FAQs match the query
            ),
          ],
        ),
      ),
    );
  }

  // Build the search bar
  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search FAQs',
        prefixIcon: Icon(Icons.search, color: Colors.brown.shade700),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  // Build the list of filtered FAQs
  Widget _buildFaqList(List<Map<String, String>> faqs) {
    return ListView.builder(
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            title: Text(
              faq['question']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),
            subtitle: Text(
              faq['answer']!,
              style: TextStyle(color: Colors.brown.shade600),
            ),
            leading: Icon(Icons.help_outline, color: Colors.brown.shade700),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          ),
        );
      },
    );
  }

  // Build "No results found" message
  Widget _buildNoResultsFound() {
    return Center(
      child: Text(
        'No results found for "$_searchQuery".',
        style: TextStyle(
          color: Colors.brown.shade600,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
