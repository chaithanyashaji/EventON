

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/admin/admhome.dart';
import 'package:universe2024/org/home.dart';
import 'package:universe2024/pages/Forget.dart';
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
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Corner Logo
          Positioned(
            top: 45,
            right: 20,
            child: Image.asset(
              'assets/EventOn.png',
              width: 100, // Adjust size as needed
            ),
          ),

          // Centered Content
          Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Gap(150),  // Adjust the gap to push content down

                  // Email Field
                  Container(
                    width: fieldWidth,
                    child: TextFormField(
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const Gap(20),

                  // Password Field
                  Container(
                    width: fieldWidth,
                    child: TextFormField(
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 1.5),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),

                  const Gap(20),

                  // Forgot Password Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      'Forgotten Password?',
                      style: TextStyle(
                        color: Styles.blueColor,
                      ),
                    ),
                  ),

                  const Gap(20),

                  // Login Button
                  Container(
                    width: fieldWidth,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Styles.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const Gap(10),

                  if (_loginError)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Username or password is wrong',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  const Gap(50),

                  // Sign Up Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Loginas()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Styles.blueColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    try {
      final user = await _auth.LoginWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        route();
      } else {
        setState(() {
          _loginError = true;
        });
        print("Some error occurred during login");
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('roll') == 'Community' &&
            documentSnapshot.get('status') == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Admin not approved yet, Please contact the admin'),
            ),
          );
        } else if (documentSnapshot.get('roll') == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userId: documentSnapshot.id,),
            ),
          );
        } else if (documentSnapshot.get('roll') == 'Admin'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Admhome(),
            ),
          );
        }
        else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SocHomePage(
                userId: documentSnapshot.id,
              ),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }
}
