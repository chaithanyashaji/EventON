import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/admin/admhome.dart';

class Admaddevent extends StatefulWidget {
  const Admaddevent({Key? key, required this.userID}) : super(key: key);

  final String userID;

  @override
  State<Admaddevent> createState() => _Admaddevent();
}

class _Admaddevent extends State<Admaddevent> {
  String imageUrl = '';
  bool _isLoading = false; // Add a variable to handle loading state

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _registrationDeadlineController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  File? _image; // Selected image file

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _registrationDeadlineTime;

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _registrationDeadlineController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedStartDate != null && pickedStartDate != _startDate) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime(2101),
      );

      if (pickedEndDate != null && pickedEndDate != _endDate) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
        });
      }
    }
  }

  Future<void> _selectRegistrationDeadline() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _registrationDeadlineTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != _registrationDeadlineTime) {
      setState(() {
        _registrationDeadlineTime = pickedTime;
        _registrationDeadlineController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
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
                                  _buildTextField("Event Name", _eventNameController),
                                  const SizedBox(height: 10),
                                  _buildTextField("Event Venue", _eventLocationController),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _selectDateRange,
                                          child: AbsorbPointer(
                                            child: _buildTextField(
                                              "Event Date Range",
                                              TextEditingController(
                                                text: _startDate != null && _endDate != null
                                                    ? "${_startDate!.toLocal()} - ${_endDate!.toLocal()}"
                                                    : 'Select Date Range',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: _selectRegistrationDeadline,
                                    child: AbsorbPointer(
                                      child: _buildTextField(
                                        "Registration Deadline",
                                        _registrationDeadlineController,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTextField("Registration Link", _websiteController),
                                  const SizedBox(height: 10),
                                  _buildImagePicker(),
                                  const SizedBox(height: 25),
                                  Container(
                                    margin: EdgeInsets.only(left: 80, bottom: 170, right: 80),
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
                                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
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
                      ? Center(child: Text('No image selected'))
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User is not authenticated.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String eventName = _eventNameController.text;
    String eventLocation = _eventLocationController.text;
    String eventWebsite = _websiteController.text;

    if (eventName.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _registrationDeadlineTime == null ||
        eventLocation.isEmpty ||
        eventWebsite.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    DateTime eventStartDate = _startDate!;
    DateTime eventEndDate = _endDate!;
    DateTime registrationDeadline = DateTime(
      eventStartDate.year,
      eventStartDate.month,
      eventStartDate.day,
      _registrationDeadlineTime!.hour,
      _registrationDeadlineTime!.minute,
    );

    if (_image != null) {
      try {
        imageUrl = await uploadImageToFirebase(_image!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('adminEvents').add({
        'eventName': eventName,
        'eventStartDate': Timestamp.fromDate(eventStartDate),
        'eventEndDate': Timestamp.fromDate(eventEndDate),
        'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        'eventLocation': eventLocation,
        'eventContact': eventWebsite,
        'imageUrl': imageUrl,
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Admhome(userId: widget.userID)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading event: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
