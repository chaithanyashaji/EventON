import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readmore/readmore.dart';
import 'package:gap/gap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universe2024/org/EditEventScreen.dart';

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
  String _addedBy = '';
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = getCurrentUserId();
    _stream = FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .snapshots();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .get();

    setState(() {
      _userRole = userDoc['roll'] ?? ''; // Handle null values
    });
  }

  Future<void> _fetchEventAdder() async {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .get();

    setState(() {
      _addedBy = eventDoc['addedBy'] ?? ''; // Handle null values
    });
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  void _editEvent() {
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
          _fetchEventAdder(); // Fetch who added the event

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildEventHeader(eventData),
                _buildEventDetails(eventData),
                _buildActionButtons(),
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
              if ( _addedBy == _currentUserId) ...[
                _buildIconButton(
                  icon: Icons.edit,
                  onPressed: _editEvent,
                  color: Colors.black,
                ),
                Gap(8),
                _buildIconButton(
                  icon: Icons.delete,
                  onPressed: _deleteEvent,
                  color: Colors.black,
                ),
              ],
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

  Widget _buildIconButton({
    required IconData icon,
    required void Function()? onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_userRole == 'student') {
      if (!_isRegistrationOpen) {
        return Container();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Handle event registration
                },
                icon: Icon(Icons.event, color: Colors.white),
                label: Text("Register", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      );
    } else if (  _addedBy == _currentUserId ) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _editEvent,
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text("Edit Event", style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _deleteEvent,
                icon: Icon(Icons.delete, color: Colors.white),
                label: Text("Delete Event", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
