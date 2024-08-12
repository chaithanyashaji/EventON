import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/firebase.dart';
import 'package:universe2024/pages/loginpage.dart';

class orgsignup extends StatefulWidget {
  const orgsignup({Key? key});

  @override
  State<orgsignup> createState() => _orgsignupState();
}

class _orgsignupState extends State<orgsignup> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final ImagePicker _picker = ImagePicker();

  File? _image; // Variable to store the selected image

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _ConpasswordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _collegeNameController = TextEditingController();

  String _errorText = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ConpasswordController.dispose();
    _nameController.dispose();
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

                  // Organization Name Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Organization Name", _nameController),
                  ),

                  const Gap(20),

                  // Email Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("Organization Email", _emailController),
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

                  // College Name Field
                  Container(
                    width: fieldWidth,
                    child: _buildTextField("College Name", _collegeNameController),
                  ),

                  const Gap(20),

                  // Profile Image Picker
                  Container(
                    width: fieldWidth,
                    child: _buildImagePicker(),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorText,
                        style: TextStyle(color: Colors.red),
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
        keyboardType: label == 'Organization Email'
            ? TextInputType.emailAddress
            : TextInputType.text,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            readOnly: true, // Make the field read-only
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              suffixIcon: GestureDetector(
                onTap: _pickImage,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _image == null
                        ? Icon(Icons.add_a_photo, color: Colors.black)
                        : Image.file(_image!, width: 40, height: 40),
                  ],
                ),
              ),
            ),
            controller: TextEditingController(
              text: _image == null ? 'Select Profile Image' : 'Image selected',
            ),
          ),
        ],
      ),
    );
  }




  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _signUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String Confirmpassword = _ConpasswordController.text;
    String name = _nameController.text;
    String collegeName = _collegeNameController.text;

    // Check if any of the fields are empty
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        collegeName.isEmpty) {
      // Update error message
      setState(() {
        _errorText = 'All fields are required';
      });
      return;
    }
    if (password != Confirmpassword) {
      setState(() {
        _errorText = 'Passwords do not match';
      });
    } else {
      try {
        // Perform sign up
        User? user = await _auth.signUpWithEmailAndPassword(email, password);

        if (user != null) {
          print("User is successfully created");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => loginpage()),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': name,
            'email': email,
            'collegeName': collegeName,
            'roll': 'Community',
            'status': 'pending',
            // Save the image URL if available
            'imageUrl': _image != null ? 'path/to/your/uploaded/image' : null,
          });
        } else {
          print("Some error");
        }
      } catch (e) {
        // Update error message
        setState(() {
          _errorText = 'Error: $e';
        });
        print("Error during sign up: $e");
    }
    }
    }
}