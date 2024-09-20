import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/admin/admhome.dart';
import 'package:intl/intl.dart';
import 'package:universe2024/Utiles/app_styles.dart';

class AdmAddEvent extends StatefulWidget {
  const AdmAddEvent({Key? key}) : super(key: key);



class Admaddevent extends StatefulWidget {
  const Admaddevent({Key? key, required this.userID}) : super(key: key);

  final String userID;


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

class _Admaddevent extends State<Admaddevent> {
  String imageUrl = '';
  bool _isLoading = false; // Add a variable to handle loading state

  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _registrationDeadlineController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();
  File? _image; // Selected image file
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb

  final ImagePicker _picker = ImagePicker();

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _registrationDeadlineTime;

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
<<<<<<< HEAD
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
=======
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
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
<<<<<<< HEAD
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
=======
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
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
<<<<<<< HEAD
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
=======
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
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
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
<<<<<<< HEAD
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
=======
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
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
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
<<<<<<< HEAD
              bottom: 10, // Positioning for the floating action button
              right: 10,
              child: FloatingActionButton(
                onPressed: _pickImage,
                backgroundColor: Colors.black, // Set background color to black
                foregroundColor: Colors.white, // Set icon color to white
                child: Icon(Icons.add_a_photo),
=======
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
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
              ),
            ),
          ],
        ),
      ],
    );
  }

<<<<<<< HEAD


=======
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }
<<<<<<< HEAD
=======

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
>>>>>>> eb0a553d04ea96fb7a60edb82af1810bcccddadb
}
