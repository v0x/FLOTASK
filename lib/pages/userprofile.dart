import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flotask/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();

  final ImagePicker _picker = ImagePicker();
  String? _profilePicturePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page initializes
  }

  /// Load user data from Firestore
  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get();

        if (document.exists) {
          Map<String, dynamic> data = document.data()!;
          setState(() {
            print(data);
            usernameController.text = data['username'] ?? '';
            emailController.text = data['email'] ?? '';
            _profilePicturePath = data['profilePicture'] ?? 'assets/default_profile_pic.png';
            isLoading = false;
          });
        } else {
          print("No document found for this user.");
          setState(() => isLoading = false);
        }
      } catch (e) {
        print("Error loading user data: $e");
        setState(() => isLoading = false);
      }
    }
  }

  /// Change profile picture
  Future<void> _changeProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profilePicturePath = image.path; // Temporarily show new image path
        });

        // Update Firestore with the profile picture path
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .update({'profilePicture': image.path});

        print("Profile picture updated: ${image.path}");
      }
    } catch (e) {
      print("Error changing profile picture: $e");
    }
  }

  /// Save username to Firestore
  Future<void> _saveUsername() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({'username': usernameController.text});
      print("Username saved: ${usernameController.text}");
    } catch (e) {
      print("Error saving username: $e");
    }
  }

  /// Save email to Firestore
  Future<void> _saveEmail() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({'email': emailController.text});
      print("Email saved: ${emailController.text}");
    } catch (e) {
      print("Error saving email: $e");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
            }, // Logout functionality
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _profilePicturePath != null
                                ? (_profilePicturePath!.startsWith('assets')
                                    ? AssetImage(_profilePicturePath!) as ImageProvider
                                    : FileImage(File(_profilePicturePath!)))
                                : AssetImage('assets/default_profile_pic.png'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 18,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      focusNode: _usernameFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.save),
                          onPressed: _saveUsername,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.save),
                          onPressed: _saveEmail,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Colors.green, content: Text('Password reset email sent to ${emailController.text.trim()}'))
                        );
                      }, 
                      child: Text(
                        'Reset Password',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
