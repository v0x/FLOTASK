import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text('Support & Help'),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Need Help?'),
              SizedBox(height: 16),
              _buildContentText(
                'Our support team is here to help you with any questions or issues you may have with FloTask. We’re available 24/7 to assist you.'
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Contact Information'),
              SizedBox(height: 16),
              _buildContactInfo(Icons.email, 'Email', 'support@flotask.com'),
              _buildContactInfo(Icons.phone, 'Phone', '+1-800-555-1234'),
              _buildContactInfo(Icons.language, 'Website', 'www.flotask.com/support'),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Action when "Contact Support" is pressed
                    _contactSupport();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Contact Support'),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'We’re here for you!',
                  style: TextStyle(
                    color: Colors.brown.shade600,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.brown.shade700,
      ),
    );
  }

  // Helper method to build content text
  Widget _buildContentText(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.brown.shade600,
        height: 1.5, // Line height for better readability
      ),
    );
  }

  // Helper method to build contact info rows
  Widget _buildContactInfo(IconData icon, String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown.shade700),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                info,
                style: TextStyle(
                  color: Colors.brown.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dummy function to simulate contacting support
  void _contactSupport() {
    // You can link this to an actual function or email intent in a real app
    print("Contact support button pressed");
  }
}
