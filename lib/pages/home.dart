import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final pageIndex;
  const HomePage({this.pageIndex, super.key, required VoidCallback toggleTheme, required bool isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> items = [];
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Test data',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendDataToFirestore,
              child: Text('Submit'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, pageIndex) {
                  return ListTile(
                    title: Text(items[pageIndex]),
                  );
                },
              ),
            ),
          ],
        ));
  }

  void fetchDataFromFirestore() {
    FirebaseFirestore.instance
        .collection('data')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((data) {
      items.clear();
      data.docs.forEach((doc) => items.add(doc['text']));
      setState(() {});
    });
  }

  void _sendDataToFirestore() {
    String inputText = _controller.text;
    if (inputText.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('data')
          .add({
            'text': inputText,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .then((value) => print("Data Added"))
          .catchError((error) => print("Failed to add data: $error"));

      _controller.clear();
    }
  }
}
