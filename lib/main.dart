import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flotask/components/NavBar.dart'; // Import the RootLayout component

void main() async {
  // Ensure proper initialization of Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

// Main entry point of the app
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primaryColor: Color(0xFFF8F8F8), // Pastel white as the primary color
        scaffoldBackgroundColor: Color(0xFFF8F8F8), // Pastel white background
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFF8F8F8), // Ensure pastel white is used throughout
        ),
      ),
      home: RootLayout(), // Use the RootLayout component as the home screen
    );
  }
}
