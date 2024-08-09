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

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

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
            Text(
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
            _buildCommunityTypeDropdown(), // Added Community Dropdown here
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
            _buildTextField("Event Description", _eventDescriptionController), // Added Event Description here
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
              decoration: InputDecoration(
                labelText: '',
                labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
              maxLines: label == 'Event Description' ? 5 : 1, // Allow multiple lines for description
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
                style: TextStyle(
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
              decoration: InputDecoration(
                labelText: '',
                labelStyle: TextStyle(color: Colors.black, fontSize: 16),
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
                style: TextStyle(
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

  Widget _buildImagePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Image',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _selectImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: _image == null
                  ? const Icon(Icons.add_a_photo, color: Colors.black, size: 50)
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Widget _buildEventTypeDropdown() {
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
            child: DropdownButtonFormField<String>(
              value: _selectedEventType,
              onChanged: (value) {
                setState(() {
                  _selectedEventType = value!;
                });
              },
              items: <String>['Competition', 'Networking', 'Workshop', 'Other']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 10,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text(
                "Type of Event",
                style: TextStyle(
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

  Widget _buildCommunityTypeDropdown() {
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
            child: DropdownButtonFormField<String>(
              value: _selectedCommunityType,
              onChanged: (value) {
                setState(() {
                  _selectedCommunityType = value!;
                });
              },
              items: <String>['IEEE', 'YEC', 'BNI', 'LEO', 'LEO', 'Rotary', 'Roundtable', 'Other']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 10,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text(
                "Type of Community",
                style: TextStyle(
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

    String? downloadUrl;
    if (_image != null) {
      downloadUrl = await _uploadImageToFirebase(_image!);
    }

    await FirebaseFirestore.instance.collection('events').add({
      'name': eventName,
      'type': _selectedEventType == 'Other' ? otherEventType : _selectedEventType,
      'community': communityType,
      'date': eventDate,
      'location': eventLocation,
      'price': eventPrice,
      'deadline': deadline,
      'notification_phrase': notificationPhrase,
      'description': eventDescription,
      'image_url': downloadUrl,
    });

    if (notificationPhrase.isNotEmpty) {
      await _sendPushNotification(notificationPhrase);
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => SocHomePage()));
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child('event_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      return await storageTaskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _sendPushNotification(String notificationPhrase) async {
    String? token = await _firebaseMessaging.getToken();
    String? serverKey = dotenv.env['FIREBASE_SERVER_KEY'];
    if (serverKey == null || token == null) return;

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(<String, dynamic>{
        'notification': <String, dynamic>{
          'body': notificationPhrase,
          'title': 'New Event Notification',
        },
        'priority': 'high',
        'to': token,
      }),
    );

    if (response.statusCode != 200) {
      print('Error sending push notification: ${response.statusCode}');
    }
  }
}
