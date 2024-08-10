import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/home.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth

class AddEvent extends StatefulWidget {

  String userID;
   AddEvent({Key? key ,required this.userID}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEvent> {
  String imageUrl = '';
  File? _image;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventPriceController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _otherEventTypeController = TextEditingController();
  final TextEditingController _notificationPhraseController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _communityTypeController = TextEditingController();

  String _selectedEventType = 'Competition';
  String _selectedCommunityType = 'IEEE';
  String _errorText = '';

  final ImagePicker _picker = ImagePicker();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventLocationController.dispose();
    _eventPriceController.dispose();
    _deadlineController.dispose();
    _otherEventTypeController.dispose();
    _notificationPhraseController.dispose();
    _communityTypeController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(
              "assets/EventOn.png",
              height: 33,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Give your event details here:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Styles.blueColor,
                ),
              ),
            ),
            const SizedBox(height: 35),
            _buildTextField("Name of the Event", _eventNameController),
            const SizedBox(height: 20),
            _buildCommunityTypeDropdown(),
            if (_selectedCommunityType == 'Other') _buildTextField("Specify Community", _communityTypeController),
            const SizedBox(height: 20),
            _buildEventTypeDropdown(),
            if (_selectedEventType == 'Other') _buildTextField("Specify Event Type", _otherEventTypeController),
            const SizedBox(height: 20),
            _buildDateField("Date of the Event", _eventDateController),
            const SizedBox(height: 20),
            _buildTextField("Event Location", _eventLocationController),
            const SizedBox(height: 20),
            _buildTextField("Event Price", _eventPriceController),
            const SizedBox(height: 20),
            _buildDateField("Deadline", _deadlineController),
            const SizedBox(height: 20),
            _buildTextField("Notification Phrase (Optional)", _notificationPhraseController),
            const SizedBox(height: 20),
            _buildTextField("Event Description", _eventDescriptionController),
            const SizedBox(height: 30),
            _buildImagePicker(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.blueColor,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  _errorText,
                  style: const TextStyle(color: Colors.red),
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
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1.5),
                top: BorderSide(color: Colors.black, width: 1.5),
                left: BorderSide(color: Colors.black, width: 1.5),
                right: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: '',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
              maxLines: label == 'Event Description' ? 5 : 1,
            ),
          ),
          Positioned(
            top: -10,
            left: 10,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1.5),
                top: BorderSide(color: Colors.black, width: 1.5),
                left: BorderSide(color: Colors.black, width: 1.5),
                right: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.black),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    controller.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                  });
                }
              },
            ),
          ),
          Positioned(
            top: -10,
            left: 10,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.5),
          top: BorderSide(color: Colors.black, width: 1.5),
          left: BorderSide(color: Colors.black, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedEventType,
          onChanged: (String? newValue) {
            setState(() {
              _selectedEventType = newValue!;
            });
          },
          items: <String>['Competition', 'Workshop', 'Seminar', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCommunityTypeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 1.5),
          top: BorderSide(color: Colors.black, width: 1.5),
          left: BorderSide(color: Colors.black, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCommunityType,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCommunityType = newValue!;
            });
          },
          items: <String>['IEEE', 'IEDC', 'CSI', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Text(
            'Upload Event Banner:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: _image == null
                  ? const Center(
                child: Text(
                  'Tap to select image',
                  style: TextStyle(color: Colors.black),
                ),
              )
                  : Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> _uploadImageToFirebase(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('event_images/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _signUp() async {
    final eventName = _eventNameController.text;
    final eventDate = _eventDateController.text;
    final eventLocation = _eventLocationController.text;
    final eventPrice = _eventPriceController.text;
    final deadline = _deadlineController.text;
    final otherEventType = _otherEventTypeController.text;
    final notificationPhrase = _notificationPhraseController.text;
    final eventDescription = _eventDescriptionController.text;
    final communityType = _selectedCommunityType == 'Other'
        ? _communityTypeController.text
        : _selectedCommunityType;


    if (eventName.isEmpty || eventDate.isEmpty || eventLocation.isEmpty || eventPrice.isEmpty || deadline.isEmpty) {
      setState(() {
        _errorText = 'Please fill all required fields.';
      });
      return;
    }

    setState(() {
      _errorText = '';
    });

    // Assuming the user is logged in and their UID is available
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    String? downloadUrl;
    if (_image != null) {
      downloadUrl = await _uploadImageToFirebase(_image!);
    }

    String id=DateTime.now().microsecondsSinceEpoch.toString();

    FirebaseFirestore.instance.collection('EVENTS').doc(id).set({
      'eventName': eventName,
      'eventType': _selectedEventType == 'Other' ? otherEventType : _selectedEventType,
      'community': communityType,
      'eventDate': eventDate,
      'eventLocation': eventLocation,
      'eventPrice': eventPrice,
      'deadline': deadline,
      'notificationPhrase': notificationPhrase,
      'description': eventDescription,
      'imageUrl': downloadUrl,
      'addedby': widget.userID,
      'isRegistrationOpen': true,
    });


    FirebaseFirestore.instance.collection('EVENTS').where("addedby",isEqualTo:widget.userID ).get().then((value) {


    //   add to user profile list





    });




    // await userDoc.collection('events').add({
    //   'eventName': eventName,
    //   'eventType': _selectedEventType == 'Other' ? otherEventType : _selectedEventType,
    //   'community': communityType,
    //   'eventDate': eventDate,
    //   'eventLocation': eventLocation,
    //   'eventPrice': eventPrice,
    //   'deadline': deadline,
    //   'notificationPhrase': notificationPhrase,
    //   'description': eventDescription,
    //   'imageUrl': downloadUrl,
    // });

    // Show notification
    _showNotification("Event Created", "Your event '$eventName' has been successfully created!");

    // Navigate to Home page after successful submission
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SocHomePage(userId: widget.userID,)),
    );
  }
}