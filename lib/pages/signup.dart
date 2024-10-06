import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//initialize FirebaseAuth instance
final FirebaseAuth _auth = FirebaseAuth.instance;

//define the signup page as a stateful widget
class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  //controllers for email and password input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Track if registration is successul
  bool _success = false; // Initialize with a default value
  String _userEmail = ''; //initialize with an empty string
  String _errorMessage = ''; // Initialize with an empty string

  //handle user registration
  void _register() async {
    setState(() {
      _errorMessage = ''; // Clear previous error message
    });

    try {
      final User? user = (await _auth.createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text))
          .user;

      //if registration is successful, update the state with successul message
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = user.email!;
          _errorMessage = ''; // Clear any previous error messages
        });

        //if register failed
      } else {
        setState(() {
          _success = false;
          _errorMessage = "Registration failed. Please try again.";
        });
      }
    } catch (e) {
      //display an error message
      setState(() {
        _success = false;
        _errorMessage = e.toString(); // Set the error message for display
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit
                      .cover, // Make the image cover the entire background
                ),
              ),
            ),
            SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //header text for creating account
                Container(
                    child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 330, 0, 0),
                      child: Text("Create your account",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    )
                  ],
                )),
                //form fields for email and password
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 30),
                  child: Column(
                    children: <Widget>[
                      //email input field
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
                            )),
                        keyboardType: TextInputType
                            .visiblePassword, // Example to avoid emoji
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      //password input field
                      TextField(
                        controller: _passwordController,
                        //obscureText: true, // Keep password hidden
                        decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            labelStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            )),
                        keyboardType: TextInputType
                            .visiblePassword, // Example to avoid emoji
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      //Signup button
                      Container(
                        height: 40,
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: Colors.green,
                          color: Colors.black,
                          elevation: 7,
                          //on Tap, attempt to register the user
                          child: GestureDetector(
                              onTap: () async {
                                _register();
                              },
                              child: Center(
                                  child: Text('SIGN UP',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat')))),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      // Display success or error message
                      if (_success)
                        Text(
                          'Successfully registered as $_userEmail',
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (!_success && _errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      //GO BACK button to nevigate to login page
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop(); //navigate back
                            },
                            child: Text('GO BACK',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ))
          ],
        )));
  }
}
