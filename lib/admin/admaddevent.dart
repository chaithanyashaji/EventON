import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:universe2024/Utiles/app_styles.dart';

class AdmAddEvent extends StatefulWidget {
  const AdmAddEvent({Key? key}) : super(key: key);

  @override
  State<AdmAddEvent> createState() => _AdmAddEventState();
}

class _AdmAddEventState extends State<AdmAddEvent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventContactController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _WebsiteController = TextEditingController();
  File? _image;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventContactController.dispose();
    _WebsiteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _signUp() async {
    if (_image == null ||
        _eventNameController.text.isEmpty ||
        _eventLocationController.text.isEmpty ||
        _eventContactController.text.isEmpty ||
    _WebsiteController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and upload an image.')),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String imageUrl = await _uploadImageToFirebase(_image!);
        await _firestore.collection('adminEvents').add({
          'eventName': _eventNameController.text,
          'eventLocation': _eventLocationController.text,
          'registrationLink': _WebsiteController.text,
          'eventContact':_eventContactController.text,
          'eventDate': selectedDate,
          'eventTime': selectedTime!.format(context),
          'imageUrl': imageUrl,
          'createdBy': user.email,
          'createdAt': Timestamp.now(),
        });

        // Stay on the page, just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    } catch (e) {
      print('Error saving event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving event: $e')),
      );
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = 'event_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Give your event details here:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Styles.blueColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Event Name", _eventNameController),
              const SizedBox(height: 20),
              _buildTextField("Event Location", _eventLocationController),
              const SizedBox(height: 20),
              _buildDateSelector(context),
              const SizedBox(height: 20),
              _buildTimeSelector(context),
              const SizedBox(height: 20),
              _buildTextField("Registration Link", _WebsiteController),
            const SizedBox(height: 20),
          _buildTextField("Event Contact", _eventContactController),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 30),
              ElevatedButton(
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
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Styles.blueColor, width: 1.5),
        ),
        hintText: label,
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Styles.yellowColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? 'Select Date'
                  : DateFormat.yMd().format(selectedDate!),
              style: TextStyle(color: Styles.blueColor),
            ),
            Icon(Icons.calendar_today, color: Styles.blueColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Styles.yellowColor, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedTime == null
                  ? 'Select Time'
                  : selectedTime!.format(context),
              style: TextStyle(color: Styles.blueColor),
            ),
            Icon(Icons.access_time, color: Styles.blueColor),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Poster',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Styles.blueColor,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 200, // Set height for the container
              width: double.infinity, // Set width to take the full width of the screen
              decoration: BoxDecoration(
                border: Border.all(
                  color: Styles.yellowColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200], // Set a background color if no image is selected
              ),
              child: _image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover, // Make sure the image covers the entire container
                ),
              )
                  : const Center(
                child: Icon(
                  Icons.photo,
                  color: Colors.black,
                  size: 50,
                ),
              ),
            ),
            Positioned(
              bottom: 10, // Positioning for the floating action button
              right: 10,
              child: FloatingActionButton(
                onPressed: _pickImage,
                backgroundColor: Colors.black, // Set background color to black
                foregroundColor: Colors.white, // Set icon color to white
                child: Icon(Icons.add_a_photo),
              ),
            ),
          ],
        ),
      ],
    );
  }



  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }
}
