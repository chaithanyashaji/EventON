import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universe2024/org/home.dart';

class AddEvent extends StatefulWidget {
  final String userID;
  AddEvent({Key? key, required this.userID}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEvent> {
  File? _image;
  String _selectedEventType = '';
  String _selectedCommunityType = '';
  String _selectedEventPrice = 'Free';
  String _errorText = '';
  bool _isSubmitting = false;
  List<String> _selectedDates = [];

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventPricePaidController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _otherEventTypeController = TextEditingController();
  final TextEditingController _notificationPhraseController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _communityTypeController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
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
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventPricePaidController.dispose();
    _deadlineController.dispose();
    _otherEventTypeController.dispose();
    _notificationPhraseController.dispose();
    _communityTypeController.dispose();
    _eventDescriptionController.dispose();
    _eventTimeController.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Give your event details here:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 35),
            _buildTextField("Name of the Event", _eventNameController),
            const SizedBox(height: 20),
            _buildCommunityTypeDropdown(),
            if (_selectedCommunityType == 'Other') _buildTextField(
                "Specify Community", _communityTypeController),
            const SizedBox(height: 20),
            _buildEventTypeDropdown(),
            if (_selectedEventType == 'Other') _buildTextField(
                "Specify Event Type", _otherEventTypeController),
            const SizedBox(height: 20),
            _buildMultipleDatePicker(),
            const SizedBox(height: 20),
            _buildTextField("Event Location", _eventLocationController),
            const SizedBox(height: 20),
            _buildEventTimePicker(),
            const SizedBox(height: 20),
            _buildEventPriceDropdown(),
            if (_selectedEventPrice == 'Paid') _buildTextField(
                "Event Price", _eventPricePaidController),
            const SizedBox(height: 20),
            _buildDateField("Deadline", _deadlineController),
            const SizedBox(height: 20),
            _buildTextField("Notification Phrase (Optional)",
                _notificationPhraseController),
            const SizedBox(height: 20),
            _buildTextField("Event Description", _eventDescriptionController),
            const SizedBox(height: 30),
            _buildImagePicker(),
            const SizedBox(height: 30),
            _isSubmitting
                ? Center(child: CircularProgressIndicator())
                : Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _signUp,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                labelText: '',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 15),
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
                  fontSize: 16,
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              readOnly: true,
              decoration: InputDecoration(
                labelText: '',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 15),
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
                    controller.text =
                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
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
                  fontSize: 16,
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
    List<String> eventTypeOptions = [
      'Conference',
      'Seminar',
      'Workshop',
      'Meetup',
      'Webinar',
      'Other',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEventType.isEmpty ? null : _selectedEventType,
        items: eventTypeOptions.map((String eventType) {
          return DropdownMenuItem<String>(
            value: eventType,
            child: Text(eventType, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEventType = newValue!;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Event Type',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCommunityTypeDropdown() {
    List<String> communityTypeOptions = [
      'Technology',
      'Art',
      'Science',
      'Culture',
      'Other',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCommunityType.isEmpty ? null : _selectedCommunityType,
        items: communityTypeOptions.map((String communityType) {
          return DropdownMenuItem<String>(
            value: communityType,
            child: Text(
                communityType, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCommunityType = newValue!;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Community Type',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEventPriceDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEventPrice,
        items: [
          DropdownMenuItem<String>(
            value: 'Free',
            child: Text('Free', style: const TextStyle(color: Colors.black)),
          ),
          DropdownMenuItem<String>(
            value: 'Paid',
            child: Text('Paid', style: const TextStyle(color: Colors.black)),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            _selectedEventPrice = newValue!;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Event Price',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMultipleDatePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Event Dates",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDates.add(
                          "${pickedDate.day}-${pickedDate.month}-${pickedDate
                              .year}");
                    });
                  }
                },
                icon: const Icon(Icons.add, color: Colors.black),
              ),
            ],
          ),
          Wrap(
            children: _selectedDates.map((date) {
              return Chip(
                label: Text(date),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedDates.remove(date);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTimePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextFormField(
        controller: _eventTimeController,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Event Time',
          border: InputBorder.none,
        ),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              _eventTimeController.text = pickedTime.format(context);
            });
          }
        },
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
            "Upload Image",
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
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
                image: _image != null
                    ? DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _image == null
                  ? const Icon(Icons.add_a_photo, color: Colors.black, size: 50)
                  : null,
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

  Future<void> _signUp() async {
    if (_eventNameController.text.isEmpty ||
        _selectedEventType.isEmpty ||
        _eventLocationController.text.isEmpty ||
        _eventTimeController.text.isEmpty ||
        _selectedDates.isEmpty ||
        _deadlineController.text.isEmpty ||
        _eventDescriptionController.text.isEmpty) {
      setState(() {
        _errorText = 'Please fill in all required fields';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageUrl;
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'event_images/${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_image!);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final eventDetails = {
        'eventName': _eventNameController.text,
        'eventType': _selectedEventType == 'Other' ? _otherEventTypeController
            .text : _selectedEventType,
        'eventLocation': _eventLocationController.text,
        'eventTime': _eventTimeController.text,
        'eventDates': _selectedDates,
        'eventPrice': _selectedEventPrice == 'Paid' ? _eventPricePaidController
            .text : _selectedEventPrice,
        'communityType': _selectedCommunityType == 'Other'
            ? _communityTypeController.text
            : _selectedCommunityType,
        'deadline': _deadlineController.text,
        'notificationPhrase': _notificationPhraseController.text,
        'eventDescription': _eventDescriptionController.text,
        'image': imageUrl,
        'addedBy': widget.userID,
      };

      await FirebaseFirestore.instance.collection('EVENTS').add(eventDetails);

      await _firebaseMessaging.subscribeToTopic(_selectedCommunityType);

      await _showNotification(
          'Event Added', 'Your event has been added successfully!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SocHomePage(userId: '')),
      );
    } catch (e) {
      setState(() {
        _errorText = 'Failed to add event. Please try again.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

}


