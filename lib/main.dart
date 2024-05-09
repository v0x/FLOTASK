import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Data to Firestore'),
      ),
      body: Padding(
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
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
