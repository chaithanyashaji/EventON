import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_storage/firebase_storage.dart';

import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/home.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/firebase.dart';
import 'package:universe2024/pages/loginpage.dart';

class addevent extends StatefulWidget {
  const addevent({Key? key});

  @override
  State<addevent> createState() => _SignupPageState();
}

class _SignupPageState extends State<addevent> {
  String imageUrl = '';
  final FirebaseAuthService _auth = FirebaseAuthService();
  CollectionReference _reference =
      FirebaseFirestore.instance.collection('event');

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDateController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _eventPriceController = TextEditingController();
  TextEditingController _eventTypeController = TextEditingController();
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _eventTimeController = TextEditingController();
  TextEditingController _eventpartController = TextEditingController();
  TextEditingController _eventContactController = TextEditingController();
  File? _image; // Selected image file

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventLocationController.dispose();
    _eventPriceController.dispose();
    _eventContactController.dispose();
    _eventDescriptionController.dispose();
    _eventTimeController.dispose();
    _eventTypeController.dispose();
    _eventpartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Styles.yellowColor,
                  Styles.lblueColor,
                  Styles.blueColor
                ])),
          ),
          title: Text(
            'Add Event',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          leading: SizedBox(
            width: 800, // Set the desired width
            height: double.infinity,
            child: Image.asset(
              'assets/logowhite.png',
              fit: BoxFit.fitHeight, // Adjust the fit as needed
            ),
          ),
          backgroundColor: Styles.blueColor),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Text(
                  "Give your event details here : ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Styles.blueColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField(
                              "Event Name",
                              _eventNameController,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField4(
                              "Event Type",
                              _eventTypeController,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField2(
                              " Event Description",
                              _eventDescriptionController,
                            ),
                            const SizedBox(height: 10),
                            _buildTextField(
                              "Event Venue",
                              _eventLocationController,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField3(
                                    "Date",
                                    _eventDateController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField3(
                                    "Time",
                                    _eventTimeController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField3(
                                    "Registration Fee",
                                    _eventPriceController,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTextField3(
                                    "No of participants",
                                    _eventpartController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildTextField4(
                              "Contact number",
                              _eventContactController,
                            ),
                            const SizedBox(height: 10),
                            _buildImagePicker(),
                            const SizedBox(height: 25),
                            Container(
                              margin: EdgeInsets.only(
                                  left: 80, bottom: 170, right: 80),
                              child: ElevatedButton(
                                onPressed: _signUp,
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 19,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.blueColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            Gap(30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
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
                color: Styles.blueColor,
              ),
            ),
          ),
          Container(
            height: 75,
            decoration: BoxDecoration(
              border: Border.all(color: Styles.yellowColor, width: 1.25),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                )
              ],
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Styles.blueColor),
              maxLines: null,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 10,
                ),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField2(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
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
                color: Styles.blueColor,
              ),
            ),
          ),
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Styles.yellowColor, width: 1.25),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                )
              ],
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Styles.blueColor),
              maxLines: null,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 10,
                ),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField3(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 10),
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
                color: Styles.blueColor,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 20),
            height: 35,
            width: MediaQuery.of(context).size.width / 2.16,
            decoration: BoxDecoration(
              border: Border.all(color: Styles.yellowColor, width: 1.25),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                )
              ],
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Styles.blueColor),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 10,
                ),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField4(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
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
                color: Styles.blueColor,
              ),
            ),
          ),
          Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Styles.yellowColor, width: 1.25),
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 1,
                )
              ],
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Styles.blueColor),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 10,
                ),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(fontSize: 13),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 30),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Event Poster',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Styles.blueColor,
            ),
          ),
        ),
        Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 150,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Styles.yellowColor,
                      width: 1.25,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1,
                      )
                    ],
                  ),
                  child: _image == null
                      ? Center(
                          child: Text(
                            'No image selected',
                            style: TextStyle(color: Styles.blueColor),
                          ),
                        )
                      : Image.file(_image!),
                ),
                Container(
                  height: 60,
                  color: Colors.white,
                ),
              ],
            ),
            Positioned(
              top: 126,
              left: 80,
              child: Container(
                margin: EdgeInsets.only(left: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        galleryImagePicker();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Styles.blueColor,
                          ),
                          Text(
                            'Pick Image',
                            style: TextStyle(
                              color: Styles.blueColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> galleryImagePicker() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('images/$fileName');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void _signUp() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when the user is not authenticated
      print("User is not authenticated.");
      return;
    }

    String eventName = _eventNameController.text;
    String eventDateStr = _eventDateController.text;
    String eventLocation = _eventLocationController.text;
    String eventPrice = _eventPriceController.text;
    String eventType = _eventTypeController.text;
    String eventDetails = _eventDescriptionController.text;
    String eventTimeStr = _eventTimeController.text; // Change variable name
    String eventParticipants = _eventpartController.text;
    String eventContact = _eventContactController.text;

    if (eventName.isEmpty ||
        eventDateStr.isEmpty ||
        eventLocation.isEmpty ||
        eventPrice.isEmpty ||
        eventType.isEmpty ||
        eventDetails.isEmpty ||
        eventTimeStr.isEmpty || // Check for empty event time
        eventParticipants.isEmpty ||
        eventContact.isEmpty) {
      setState(() {
        // Show error message
      });
      return;
    }

    DateTime eventDate;
    DateTime eventTime; // Variable for event time
    try {
      // Parse the event date and time from string to DateTime
      eventDate = DateTime.parse(eventDateStr);
      eventTime = DateTime.parse(eventTimeStr); // Parse event time
    } catch (e) {
      print('Error parsing date or time: $e');
      return;
    }

    // Upload the image if one is selected
    if (_image != null) {
      imageUrl = await uploadImageToFirebase(_image!);
    }

    try {
      // Add the event to the user's events collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc() // Use .doc() to generate a new unique ID for the event
          .set({
        'eventName': eventName,
        'eventDate': Timestamp.fromDate(eventDate), // Store as Timestamp
        'eventTime':
            Timestamp.fromDate(eventTime), // Store event time as Timestamp
        'eventLocation': eventLocation,
        'eventPrice': eventPrice,
        'eventType': eventType,
        'eventDetails': eventDetails,
        'eventParticipants': eventParticipants,
        'eventContact': eventContact,
        'imageUrl': imageUrl,
      });

      // Navigate to home page upon successful upload
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                SocHomePage()), // Replace SocHomePage with your actual home page widget
      );
    } catch (error) {
      print("Error uploading event: $error");
    }
  }
}
