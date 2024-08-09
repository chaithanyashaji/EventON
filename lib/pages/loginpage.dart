import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/org/home.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/Signuppage.dart';
import 'package:universe2024/pages/Splashscreen.dart';
import 'package:universe2024/pages/firebase.dart';
import 'package:universe2024/pages/loginas.dart';

class loginpage extends StatefulWidget {
  const loginpage({Key? key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _loginError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(20, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.yellowColor,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-2.7, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.blueColor,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(2.7, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.lblueColor,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      SizedBox(
                        height:100
                      ),
                      Text(
                        "Sign-In",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(40),

                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        border: InputBorder.none,
                                        hintText: "Email",
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const Gap(10),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      enableSuggestions: false,
                                      autocorrect: false,
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                        border: InputBorder.none,
                                        hintText: "Password",
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // Submit button
                      const Gap(10),
                      TextButton(
                        onPressed: () {
                          // Add your forgot password logic here
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Styles.blueColor,
                          ),
                        ),
                      ),
                      const Gap(40),

                      Container(
                        height: 40,
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Styles.blueColor,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2)),
                            ]),
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            // Set button background color to transparent
                            elevation: 0, // Remove button elevation
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Styles.blueColor,
                            ),
                          ),
                        ),
                      ),

                      if (_loginError)
                        Text(
                          'Username or password is wrong',
                          style: TextStyle(color: Colors.red),
                        ),
                      const Gap(200),
                      // Forgot password link

                      // Signup button
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                          ),
                          const Gap(10),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Styles.blueColor,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 10,
                                      offset: Offset(2, 2)),
                                ]),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Colors
                                      .transparent), // Make button transparent
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ))),
                              onPressed: () {
                                // Navigate to the signup page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Loginas()),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    try {
      final user = await _auth.LoginWithEmailAndPassword(
          _emailController.text, _passwordController.text);

      // Navigate to home page if login is successful
      if (user != null) {
        print("User is successfully signed in");

        route();
      } else {
        // Handle unsuccessful login
        setState(() {
          _loginError = true;
        });
        print("Some error occurred during login");
      }
    } catch (e) {
      // Handle errors
      print("Error during login: $e");
      // Show error message on the screen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('roll') == "Community") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SocHomePage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }
}
