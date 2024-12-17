import 'package:flotask/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Track password visibility state
  bool _isPasswordVisible = false;

  int _success = 1;
  String _userEmail = "";

  void _signIn() async {
    final email = _emailController.text;
    final username = _usernameController.text;

    try {
      // Check if the username exists in Firestore
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isEmpty) {
        setState(() {
          _success = 3;
        });
        return;
      }

      final User? user = (await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      ))
          .user;

      if (user != null) {
        setState(() {
          _success = 2;
          _userEmail = user.email!;
        });

        // Navigate to the main app after successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _success = 3;
        });
      }
    } catch (e) {
      setState(() {
        _success = 3;
      });
      print(e.toString());
    }
  }

  void _forgotPassword() async {
    final TextEditingController _dialogEmailController =
        TextEditingController();
    final TextEditingController _dialogUsernameController =
        TextEditingController();

    // Show a dialog to enter username and email
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _dialogEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: _dialogUsernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    // Get the values from the controllers after the dialog is closed
    String email = _dialogEmailController.text.trim();
    String username = _dialogUsernameController.text.trim();

    if (email.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email and username fields cannot be empty.'),
        ),
      );
      return;
    }

    try {
      // Check if the username and email match in Firestore
      QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        // If found, navigate to the password reset screen
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: email),
        ));
      } else {
        // Show an error if username and email don't match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username and email do not match our records.'),
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15, 290, 0, 0),
                  child: Text(
                    "Login to your account",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, left: 20, right: 30),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'USERNAME',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment(1, 0),
                        padding: EdgeInsets.only(top: 15, left: 20),
                        child: InkWell(
                          onTap: () {
                            _forgotPassword();
                          },
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      // The rest of your login UI remains unchanged
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _success == 1
                              ? ''
                              : (_success == 2
                                  ? 'Successfully signed in as ' + _userEmail
                                  : 'Sign in failed. Please check your email and password.'),
                          style: TextStyle(
                            color: _success == 2 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 40,
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: Colors.green,
                          color: Colors.black,
                          elevation: 7,
                          child: GestureDetector(
                            onTap: () async {
                              _signIn();
                            },
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/signup');
                            },
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends StatelessWidget {
  final String email;

  ResetPasswordPage({required this.email});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _newPasswordController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: false,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Get the current user
                  User? user = _auth.currentUser;
                  if (user != null) {
                    // Update the user's password
                    await user.updatePassword(_newPasswordController.text);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password reset successfully.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No user is signed in.')),
                    );
                  }
                } catch (e) {
                  // Catch specific error for re-authentication
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to reset password: ${e.toString()}')),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
