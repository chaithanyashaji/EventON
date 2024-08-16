import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _eventContactController = TextEditingController();
  final TextEditingController _whatsappGroupLinkController = TextEditingController();


  final ImagePicker _picker = ImagePicker();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
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
    _eventContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Text(
                  "Add your Event",
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
            _buildMultipleDatePicker(),
            const SizedBox(height: 20),
            _buildTextField("Event Location", _eventLocationController),
            const SizedBox(height: 20),
            _buildEventTimePicker(),
            const SizedBox(height: 20),
            _buildEventPriceDropdown(),
            if (_selectedEventPrice == 'Paid') _buildTextField("Event Price", _eventPricePaidController),
            const SizedBox(height: 20),
            _buildDateField("Deadline", _deadlineController),
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
                  'Submit',
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
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Stack(
        children: [  // Changed `child` to `children`
          TextFormField(
            controller: controller,
            maxLines: label == 'Event Description' ? 5 : 1,
            decoration: InputDecoration(
              labelText: label,  // Adjusted to use the label passed to the function
              labelStyle: const TextStyle(color: Colors.black),  // Label text color to black
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)  // Border color to black
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)  // Border color when focused
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildDateField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Stack(
        children: [
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,  // Use the label passed to the function
              labelStyle: const TextStyle(color: Colors.black),  // Label text color to black
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2) // Border color to black
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2) // Border color when focused
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            readOnly: true,  // Make the TextField read-only
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                // Format the date and set it to the controller
                String formattedDate = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                controller.text = formattedDate;
              }
            },
          ),
        ],
      ),
    );
  }



  Widget _buildEventTypeDropdown() {
    List<String> eventTypeOptions = [
      'Conference',
      'Workshop',
      'Competition',
      'Webinar',
      'Other',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),

      child: Stack(
        children: [
          TextFormField(
            controller: TextEditingController(text: _selectedEventType),
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Event Type',
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(

                onChanged: (newValue) {
                  setState(() {
                    _selectedEventType = newValue!;
                  });
                },
                items: eventTypeOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                underline: SizedBox(), // No underline
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCommunityTypeDropdown() {
    List<String> communityTypeOptions = [
      'IEEE',
      'CSI',
      'IEDC',
      'Other',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),

      child: Stack(
        children: [
          TextFormField(
            controller: TextEditingController(text: _selectedCommunityType),
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Community Type',
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: DropdownButton<String>(

                onChanged: (newValue) {
                  setState(() {
                    _selectedCommunityType = newValue!;
                  });
                },
                items: communityTypeOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                underline: SizedBox(), // No underline
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEventPriceDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),

      child: Stack(
          children: [
      TextFormField(
      controller: TextEditingController(text: _selectedEventPrice),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Event Price',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2)
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

      ),
    ),
      DropdownButton<String>(


        isExpanded: true,

        underline: SizedBox(),
        onChanged: (newValue) {
          setState(() {
            _selectedEventPrice = newValue!;
          });
        },
        items: ['Free', 'Paid'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),],
      ),

    );
  }

  Widget _buildMultipleDatePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child:Stack(
      children: [ TextFormField(
        controller: TextEditingController(text: _selectedDates.join(', ')),
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Event Date(s)',
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)  // Border color to black
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2)  // Border color when focused
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal:15,vertical: 15),
        ),
        onTap: () async {
          final DateTimeRange? pickedDateRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDateRange != null) {
            setState(() {
              _selectedDates = [
                "${pickedDateRange.start.day}-${pickedDateRange.start.month}-${pickedDateRange.start.year}",
                "${pickedDateRange.end.day}-${pickedDateRange.end.month}-${pickedDateRange.end.year}"
              ];
            });
          }
        },
      ),
    ]
    )
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
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upload Image:",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _image = File(pickedFile.path);
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: _image != null
                    ? DecorationImage(
                  image: FileImage(_image!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _image == null
                  ? const Center(
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.black,
                  size: 50,
                ),
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitEvent() async {
    setState(() {
      _isSubmitting = true;
      _errorText = '';
    });

    try {
      if (_eventNameController.text.isEmpty) {
        setState(() {
          _errorText = 'Event name is required';
        });
        return;
      }

      if (_selectedEventType.isEmpty) {
        setState(() {
          _errorText = 'Please select an event type';
        });
        return;
      }

      if (_selectedCommunityType.isEmpty) {
        setState(() {
          _errorText = 'Please select a community type';
        });
        return;
      }

      if (_selectedDates.isEmpty) {
        setState(() {
          _errorText = 'Please select at least one event date';
        });
        return;
      }

      String imageUrl = '';
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('event_images').child('${DateTime.now()}.jpg');
        await storageRef.putFile(_image!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final newEvent = {
        'eventName': _eventNameController.text,
        'eventType': _selectedEventType == 'Other' ? _otherEventTypeController.text : _selectedEventType,
        'communityType': _selectedCommunityType == 'Other' ? _communityTypeController.text : _selectedCommunityType,
        'eventDates': _selectedDates,
        'eventLocation': _eventLocationController.text,
        'eventTime': _eventTimeController.text,
        'eventPrice': _selectedEventPrice == 'Paid' ? _eventPricePaidController.text : 'Free',
        'deadline': _deadlineController.text,
        'notificationPhrase': _notificationPhraseController.text,
        'eventDescription': _eventDescriptionController.text,
        'eventContact': _eventContactController.text,
        'whatsappGroupLink': _whatsappGroupLinkController.text,
        'imageUrl': imageUrl,
        'createdBy': widget.userID,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('events').add(newEvent);

      if (_notificationPhraseController.text.isNotEmpty) {
        await _showNotification("A new Event has been added", _notificationPhraseController.text);
      }

      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _errorText = error.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<List<DateTime>> showDatePickerRange({required BuildContext context}) async {
    final pickedDates = <DateTime>[];

    DateTime? firstDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (firstDate != null) {
      pickedDates.add(firstDate);

      bool continueAdding = true;
      while (continueAdding) {
        DateTime? additionalDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (additionalDate != null) {
          pickedDates.add(additionalDate);
        } else {
          continueAdding = false;
        }
      }
    }

    return pickedDates;
  }

}
