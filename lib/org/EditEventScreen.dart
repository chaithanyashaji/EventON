import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  EditEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  File? _image;
  String _selectedEventType = '';
  String _selectedCommunityType = '';
  String _selectedEventPrice = 'Free';
  String _selectedEventLevel = 'Level I';
  bool _isSubmitting = false;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventPricePaidController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _otherEventTypeController = TextEditingController();
  final TextEditingController _notificationPhraseController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _communityTypeController = TextEditingController();
  final TextEditingController _eventTimeController = TextEditingController();
  final TextEditingController _eventContactController = TextEditingController();
  final TextEditingController _whatsappGroupLinkController = TextEditingController();
  final TextEditingController _upiIDController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadEventData();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
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

  void _loadEventData() async {
    // Fetch the event data from Firestore and initialize the fields
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance.collection('EVENTS').doc(widget.eventId).get();

    if (eventSnapshot.exists) {
      setState(() {
        _eventNameController.text = eventSnapshot['name'] ?? '';
        _eventLocationController.text = eventSnapshot['location'] ?? '';
        _eventDateController.text = eventSnapshot['eventDate'] ?? '';
        _endDateController.text = eventSnapshot['endDate'] ?? '';
        _deadlineController.text = eventSnapshot['deadline'] ?? '';
        _selectedEventType = eventSnapshot['eventType'] ?? '';
        _selectedCommunityType = eventSnapshot['communityType'] ?? '';
        _selectedEventPrice = eventSnapshot['eventPrice'] ?? 'Free';
        _selectedEventLevel = eventSnapshot['eventLevel'] ?? 'Level I';
        _eventTimeController.text = eventSnapshot['eventTime'] ?? '';
        _eventDescriptionController.text = eventSnapshot['description'] ?? '';
        _eventContactController.text = eventSnapshot['contact'] ?? '';
        _whatsappGroupLinkController.text = eventSnapshot['whatsappLink'] ?? '';
        _notificationPhraseController.text = eventSnapshot['notificationPhrase'] ?? '';
        // Assuming event has an imageUrl field
        String imageUrl = eventSnapshot['imageUrl'] ?? '';
        if (imageUrl.isNotEmpty) {
          _image = File(imageUrl); // This would need proper handling to convert URL to File
        }
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventPricePaidController.dispose();
    _eventDateController.dispose();
    _endDateController.dispose();
    _deadlineController.dispose();
    _otherEventTypeController.dispose();
    _notificationPhraseController.dispose();
    _eventDescriptionController.dispose();
    _communityTypeController.dispose();
    _eventTimeController.dispose();
    _eventContactController.dispose();
    _upiIDController.dispose();
    _whatsappGroupLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Event'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Text(
                  "Edit your Event",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Name of the Event", _eventNameController),
            const SizedBox(height: 20),
            _buildCommunityTypeDropdown(),
            if (_selectedCommunityType == 'Other') _buildTextField("Specify Community", _communityTypeController),
            const SizedBox(height: 20),
            _buildEventTypeDropdown(),
            if (_selectedEventType == 'Other') _buildTextField("Specify Event Type", _otherEventTypeController),
            const SizedBox(height: 20),
            _buildDateField("Event Date", _eventDateController),
            const SizedBox(height: 20),
            _buildDateField("End Date", _endDateController),
            const SizedBox(height: 20),
            _buildTextField("Event Location", _eventLocationController),
            const SizedBox(height: 20),
            _buildEventTimePicker(),
            const SizedBox(height: 20),
            _buildEventPriceDropdown(),
            const SizedBox(height: 20),
            _buildDateField("Deadline", _deadlineController),
            const SizedBox(height: 20),
            _buildEventLevelDropdown(),
            const SizedBox(height: 20),
            _buildTextField("Notification Phrase (Optional)", _notificationPhraseController),
            const SizedBox(height: 20),
            _buildTextField("Event Description", _eventDescriptionController),
            const SizedBox(height: 20),
            _buildTextField("Event Contact", _eventContactController),
            const SizedBox(height: 20),
            _buildTextField("WhatsApp Group Link (Optional)", _whatsappGroupLinkController),
            const SizedBox(height: 30),
            _buildImagePicker(),
            const SizedBox(height: 30),
            _isSubmitting
                ? Center(child: CircularProgressIndicator())
                : Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvent,
                child: const Text(
                  'Update Event',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: label == 'Event Description' ? 5 : 1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toString().split(' ')[0];
            });
          }
        },
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedEventType,
        items: <String>['Workshop', 'Seminar', 'Conference', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Event Type',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEventType = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildCommunityTypeDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedCommunityType,
        items: <String>['Community A', 'Community B', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Community Type',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCommunityType = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildEventPriceDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedEventPrice,
        items: <String>['Free', 'Paid']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Event Price',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEventPrice = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildEventLevelDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedEventLevel,
        items: <String>['Level I', 'Level II', 'Level III']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Event Level',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEventLevel = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildEventTimePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextFormField(
        controller: _eventTimeController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Event Time',
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
    return Column(
      children: [
        _image != null
            ? Image.file(
          _image!,
          height: 150,
          width: 150,
        )
            : Container(
          height: 150,
          width: 150,
          color: Colors.grey,
          child: Icon(Icons.image, size: 50),
        ),
        TextButton(
          onPressed: _pickImage,
          child: Text("Select Event Image"),
        )
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitEvent() async {
    if (_eventNameController.text.isEmpty) {
      _showNotification('Error', 'Event name cannot be empty');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload image to Firebase Storage
      String imageUrl = '';
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('event_images/${DateTime.now().toIso8601String()}');
        final uploadTask = storageRef.putFile(_image!);
        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update event in Firestore
      await FirebaseFirestore.instance.collection('EVENTS').doc(widget.eventId).update({
        'name': _eventNameController.text,
        'location': _eventLocationController.text,
        'eventDate': _eventDateController.text,
        'endDate': _endDateController.text,
        'deadline': _deadlineController.text,
        'eventType': _selectedEventType,
        'communityType': _selectedCommunityType,
        'eventPrice': _selectedEventPrice,
        'eventLevel': _selectedEventLevel,
        'eventTime': _eventTimeController.text,
        'description': _eventDescriptionController.text,
        'contact': _eventContactController.text,
        'whatsappLink': _whatsappGroupLinkController.text,
        'notificationPhrase': _notificationPhraseController.text,
        'imageUrl': imageUrl,
      });

      _showNotification('Success', 'Event updated successfully');
      Navigator.of(context).pop();
    } catch (e) {
      _showNotification('Error', 'Failed to update event');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
