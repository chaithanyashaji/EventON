import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readmore/readmore.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/EditEventScreen.dart';
import 'package:universe2024/org/home.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/qrcode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';



class EventDetails extends StatefulWidget {
  final String eventKey;

  const EventDetails({Key? key, required this.eventKey}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Stream<DocumentSnapshot> _stream;
  bool _isRegistrationOpen = true;
  String _userRole = '';
  bool _isRegistered = false;
  String _addedBy = '';
  String _currentUserId = '';
  String _paymentStatus = '';

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .snapshots();
    _currentUserId = getCurrentUserId();
    _fetchUserRole();
    _checkRegistrationStatus();
  }

  void _fetchUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .get();
    setState(() {
      _userRole = userDoc['roll'] ?? '';;
    });
    _checkRegistrationStatus();
    _fetchEventAdder();
  }

  void _checkRegistrationStatus() async {
    QuerySnapshot registrationDocs = await FirebaseFirestore.instance
        .collection('REGISTRATIONS')
        .where('eventId', isEqualTo: widget.eventKey)
        .where('userId', isEqualTo: _currentUserId)
        .get();

    if (registrationDocs.docs.isNotEmpty) {
      DocumentSnapshot registrationDoc = registrationDocs.docs.first;
      setState(() {
        _isRegistered = true;
        _paymentStatus = registrationDoc['PaymentStatus'];
      });
    } else {
      setState(() {
        _isRegistered = false;
        _paymentStatus = '';
      });
    }
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<void> _fetchEventAdder() async {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .get();

    setState(() {
      _addedBy = eventDoc['addedby'] ?? ''; // Handle null values
    });
  }

  void _editEvent(DocumentSnapshot eventDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(eventKey: widget.eventKey),
      ),
    );
  }

  Future<void> _deleteEvent() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
        ],
      ),
    );
    if (confirm ?? false) {
      await FirebaseFirestore.instance
          .collection('EVENTS')
          .doc(widget.eventKey)
          .delete();
      Navigator.pop(context);
    }
  }

  void _registerForEvent(DocumentSnapshot eventDoc) async {
  try {
    // Step 1: Pick an image
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      // Handle case where user cancels picking an image
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
      return;
    }

    // Step 2: Upload the image to Firebase Storage
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = FirebaseStorage.instance.ref().child('payment_screenshots').child('$fileName.jpg');
    UploadTask uploadTask = storageRef.putFile(File(image.path));

    // Wait for the upload to complete
    TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL of the uploaded image
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Step 3: Register for the event
    DocumentReference registrationRef = FirebaseFirestore.instance.collection('REGISTRATIONS').doc();
    await registrationRef.set({
      'eventName': eventDoc['eventName'],
      'eventId': widget.eventKey,
      'userName': (await FirebaseFirestore.instance.collection('users').doc(_currentUserId).get())['name'],
      'userId': _currentUserId,
      'registrationId': registrationRef.id,
      'PaymentStatus': 'pending',
      'ScannedStatus': 'pending',
      'PaymentScreenshot': downloadURL,  // Store the download URL
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(userId: _currentUserId)),
    );
  } catch (e) {
    print('Error during registration: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during registration: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Event not found'));
          }

          DocumentSnapshot eventDoc = snapshot.data!;
          Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

          _isRegistrationOpen = eventData['isRegistrationOpen'] ?? true;

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildEventHeader(eventData),
                _buildEventDetails(eventData),
                _buildActionButtons(eventDoc),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventHeader(Map<String, dynamic> eventData) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Image.network(eventData['imageUrl'] ?? 'https://via.placeholder.com/300'),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: NetworkImage(eventData['imageUrl'] ?? 'https://via.placeholder.com/300'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> eventData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  eventData['eventName'] ?? 'Event Name Unavailable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, color: Colors.black),
              SizedBox(width: 8),
              Text(eventData['eventType'] ?? 'Type Unavailable', style: TextStyle(color: Colors.black)),
              Spacer(),
              Icon(Icons.date_range, color: Colors.black),
              SizedBox(width: 8),
              Text(eventData['eventDate'] ?? 'Date Unavailable', style: TextStyle(color: Colors.black)),
              Spacer(),
              Icon(Icons.access_time, color: Colors.black),
              SizedBox(width: 8),
              Text(eventData['eventTime'] ?? 'Time Unavailable', style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.black),
              SizedBox(width: 8),
              Expanded(child: Text(eventData['eventLocation'] ?? 'Location Unavailable', style: TextStyle(color: Colors.black))),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.money, color: Colors.black),
              SizedBox(width: 8),
              Text("Price: ${eventData['eventPrice'] ?? 'Unavailable'}", style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.event_note, color: Colors.black),
              SizedBox(width: 8),
              Text("Deadline: ${eventData['deadline'] ?? 'Unavailable'}", style: TextStyle(color: Colors.black)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          ReadMoreText(
            eventData['description'] ?? 'Description not available.',
            trimMode: TrimMode.Line,
            trimLines: 4,
            trimLength: 150,
            style: TextStyle(color: Colors.black),
            trimCollapsedText: 'Read More',
            trimExpandedText: 'Read less',
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

 Widget _buildActionButtons(eventDoc) {
  // Only students should see this button
  if (_userRole == 'student') {
    // If registration is not open, return an empty container
    if (!_isRegistrationOpen) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          // Register button for students who haven't registered yet
          if (_isRegistrationOpen && !_isRegistered)
            ElevatedButton.icon(
              onPressed: () => _registerForEvent(eventDoc),
              icon: Icon(Icons.event),
              label: Text('Register'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
              ),
            ),
          // Show QR Code button if payment is approved
          if (_isRegistered && _paymentStatus == 'approved')
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrGenerationScreen(id: _currentUserId,),
                  ),
                );
              },
              icon: Icon(Icons.qr_code),
              label: Text('Show QR Code'),
            ),
          // Message for pending payment verification
          if (_isRegistered && _paymentStatus == 'pending')
            Container(
              margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              child: Text(
                "Waiting for payment verification",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // If the user added the event and is not a student, show edit and delete buttons
  if (_addedBy == _currentUserId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _editEvent(eventDoc),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: _deleteEvent,
        ),
      ],
    );
  }

  // Return an empty container if no conditions are met
  return Container();
}
}