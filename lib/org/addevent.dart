import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:http/http.dart' as http;

class addevent extends StatefulWidget {
  const addevent({Key? key}) : super(key: key);

  @override
  State<addevent> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<addevent> {
  String imageUrl = '';
  File? _image;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventPriceController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _otherEventTypeController = TextEditingController();
  final TextEditingController _notificationPhraseController = TextEditingController();

  String _selectedEventType = 'Competition';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
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
        ),
    backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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

            const SizedBox(height: 50),
            _buildTextField("Name of the Event", _eventNameController),
            const SizedBox(height: 10),
            _buildDateField("Date of the Event", _eventDateController),
            const SizedBox(height: 10),
            _buildTextField("Event Location", _eventLocationController),
            const SizedBox(height: 10),
            _buildTextField("Event Price", _eventPriceController),
            const SizedBox(height: 10),
            _buildDateField("Deadline", _deadlineController),
            const SizedBox(height: 10),
            _buildEventTypeDropdown(),
            if (_selectedEventType == 'Other') _buildTextField("Specify Event Type", _otherEventTypeController),
            const SizedBox(height: 10),
            _buildTextField("Notification Phrase (Optional)", _notificationPhraseController),
            const SizedBox(height: 10),
            _buildImagePicker(),
            const SizedBox(height: 20),
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
              Text(
                _errorText,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            height: 35,
            decoration: const BoxDecoration(
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
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            height: 35,
            decoration: const BoxDecoration(
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
              style: const TextStyle(color: Colors.black),
              readOnly: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
        ],
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Event Type",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
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
            child: DropdownButton<String>(
              value: _selectedEventType,
              isExpanded: true,
              underline: Container(),
              items: <String>['Competition', 'Workshop', 'Seminar', 'Conference', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEventType = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              "Upload Poster",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                if (_image != null)
                  Image.file(_image!)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text(
                        'Pick Image',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.blueColor,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_image != null)
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: const Text(
                          'Upload Image',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Styles.blueColor,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

  Future<void> _uploadImage() async {
    if (_image == null) return;
    String fileName = _image!.path.split('/').last;
    Reference storageReference = FirebaseStorage.instance.ref().child('events/$fileName');
    UploadTask uploadTask = storageReference.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadUrl;
    });
  }

  Future<void> _signUp() async {
    String eventName = _eventNameController.text;
    String eventDate = _eventDateController.text;
    String eventLocation = _eventLocationController.text;
    String eventPrice = _eventPriceController.text;
    String deadline = _deadlineController.text;
    String eventType = _selectedEventType == 'Other'
        ? _otherEventTypeController.text
        : _selectedEventType;
    String notificationPhrase = _notificationPhraseController.text;

    if (eventName.isEmpty || eventDate.isEmpty || eventLocation.isEmpty ||
        eventPrice.isEmpty || deadline.isEmpty || eventType.isEmpty) {
      setState(() {
        _errorText = 'Please fill all the required fields.';
      });
      return;
    }

    CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
    await eventsCollection.add({
      'name': eventName,
      'date': eventDate,
      'location': eventLocation,
      'price': eventPrice,
      'deadline': deadline,
      'eventType': eventType,
      'imageUrl': imageUrl,
      'notificationPhrase': notificationPhrase,
    });

    _showNotification('New Event Added', 'Event $eventName has been added.');
    sendPushNotification(eventName, notificationPhrase);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> sendPushNotification(String title, String body) async {
    final serverKey = dotenv.env['FIREBASE_SERVER_KEY'] ?? ''; // Access environment variable
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': '/topics/all', // Or use a specific device token or topic
        'notification': {
          'title': title,
          'body': body,
        },
      }),
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
