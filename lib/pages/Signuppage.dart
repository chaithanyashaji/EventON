import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:EventON/Utiles/app_styles.dart';
import 'package:EventON/pages/firebase.dart';
import 'package:EventON/pages/loginpage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ConpasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _collegeNameController = TextEditingController();

  String _errorText = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ConpasswordController.dispose();
    _nameController.dispose();
    _mobileNumberController.dispose();
    _collegeNameController.dispose();
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

                  // Name Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Name", _nameController),
                  ),

                  const Gap(20),

                  // Email Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Email", _emailController),
                  ),

                  const Gap(20),

                  // Password Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Password", _passwordController),
                  ),

                  const Gap(20),

                  // Confirm Password Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Confirm Password", _ConpasswordController),
                  ),

                  const Gap(20),

                  // Mobile Number Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Mobile Number", _mobileNumberController),
                  ),

                  const Gap(20),

                  // College Name Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("College Name", _collegeNameController),
                  ),

                  const Gap(20),

                  // Submit Button
                  Container(
                    width: fieldWidth,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Styles.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const Gap(10),

                  // Error Text
                  if (_errorText.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _errorText,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),

                  const Gap(50),

                  // Sign In Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => loginpage()),
                          );
                        },
                        child: Text(
                          'Sign In',
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      child: TextFormField(
        controller: controller,
        obscureText: label == 'Password' || label == 'Confirm Password',
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        keyboardType: label == 'Mobile Number'
            ? TextInputType.phone
            : TextInputType.text,
      ),
    );
  }

  void _signUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String Confirmpassword = _ConpasswordController.text;
    String name = _nameController.text;
    String mobileNumber = _mobileNumberController.text;
    String collegeName = _collegeNameController.text;

    // Check if any of the fields are empty
    if (email.isEmpty ||
        password.isEmpty ||
        Confirmpassword.isEmpty ||
        name.isEmpty ||
        mobileNumber.isEmpty ||
        collegeName.isEmpty) {
      setState(() {
        _errorText = 'All fields are required';
      });
      return;
    }

    // Check if password matches the confirmation password
    if (password != Confirmpassword) {
      setState(() {
        _errorText = 'Passwords do not match';
      });
      return;
    }

    // Check for password strength
    if (!isPasswordStrong(password)) {
      setState(() {
        _errorText = 'Password must be at least 8 characters, include uppercase, lowercase, digit, and special character.';
      });
      return;
    }

    try {
      // Perform sign up
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        print("User is successfully created");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => loginpage()),
        );

        // Add user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'name': name,
          'email': email,
          'mobileNumber': mobileNumber,
          'collegeName': collegeName,
          'roll': 'student',
          'activityPoints': 0, // Initialize activity points
        });
      } else {
        print("Some error");
      }
    } catch (e) {
      setState(() {
        _errorText = 'Error: $e';
      });
      print("Error during sign up: $e");
    }
  }

  // Function to check if the password is strong
  bool isPasswordStrong(String password) {
    // Regex to check for uppercase, lowercase, digit, and special character
    final strongPasswordPattern = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return strongPasswordPattern.hasMatch(password);
  }
}
