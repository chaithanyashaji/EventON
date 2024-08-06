import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/loginpage.dart';

import '../pages/Homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddEventPage(),
    );
  }
}

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  String imageUrl = ''; // URL of the uploaded image
  File? _image; // Selected image file

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDateController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _eventPriceController = TextEditingController();

  String _errorText = '';

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventLocationController.dispose();
    _eventPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Your background decorations (if any)
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      children: [
                        // Your app logo or title
                        Image.asset(
                          'assets/logowhite.png',
                          width: 200,
                          height: 100,
                        ),
                        const SizedBox(height: 10),
                        // Sign-up text or heading
                        Text(
                          "Sign-Up",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Event name text field
                        _buildTextField("Name of the Event", _eventNameController),
                        const SizedBox(height: 10),
                        // Event date text field
                        _buildTextField("Date of the Event", _eventDateController),
                        const SizedBox(height: 10),
                        // Event location text field
                        _buildTextField("Event Location", _eventLocationController),
                        const SizedBox(height: 10),
                        // Event price text field
                        _buildTextField("Event Price", _eventPriceController),
                        const SizedBox(height: 10),
                        // Image picker widget
                        _buildImagePicker(),
                        const SizedBox(height: 20),
                        // Submit button
                        ElevatedButton(
                          onPressed: _signUp,
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.blueColor,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Display error text
                        if (_errorText.isNotEmpty)
                          Text(
                            _errorText,
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build text fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build image picker
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Event Poster',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 150,
          margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(2, 2),
              )
            ],
          ),
          child: _image == null ? Center(child: Text('No image selected')) : Image.file(_image!),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            selectImage(); // Call function to pick image
          },
          child: Text('Pick Image'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Styles.blueColor,
          ),
        ),
      ],
    );
  }

  // Method to select image from gallery
  void selectImage() async {
    try {
      final ImagePicker _imagePicker = ImagePicker();
      XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      setState(() {
        _image = File(file.path);
      });
    } catch (error) {
      setState(() {
        _errorText = "Error picking image: $error";
      });
      print("Error picking image: $error");
    }
  }

  // Method to handle form submission
  void _signUp() async {
    String eventName = _eventNameController.text;
    String eventDate = _eventDateController.text;
    String eventLocation = _eventLocationController.text;
    String eventPrice = _eventPriceController.text;

    // Check if any of the fields are empty
    if (eventName.isEmpty ||
        eventDate.isEmpty ||
        eventLocation.isEmpty ||
        eventPrice.isEmpty ||
        _image == null) {
      // Update error message
      setState(() {
        _errorText = 'All fields are required';
      });
      return;
    }

    try {
      // Upload image to Firebase Storage
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$filename');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        // Get the download URL from Firebase Storage
        String downloadUrl = await storageReference.getDownloadURL();

        // Store event details and image URL in Firestore
        await FirebaseFirestore.instance.collection('events').add({
          'eventName': eventName,
          'eventDate': eventDate,
          'eventLocation': eventLocation,
          'eventPrice': eventPrice,
          'imageUrl': downloadUrl,
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        // Navigate back to a previous screen or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event added successfully'),
          ),
        );

        // Clear the form fields and image
        setState(() {
          _eventNameController.clear();
          _eventDateController.clear();
          _eventLocationController.clear();
          _eventPriceController.clear();
          _image = null;
          _errorText = '';
        });
      });
    } catch (error) {
      setState(() {
        _errorText = "Error uploading image and adding event: $error";
      });
      print("Error uploading image and adding event: $error");
    }
    }
}
