import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EventDetails.dart'; // Import the EventDetails page

class RegisteredEvent extends StatefulWidget {
  const RegisteredEvent({super.key});

  @override
  _RegisteredEventState createState() => _RegisteredEventState();
}

class _RegisteredEventState extends State<RegisteredEvent> {
  int _activityPoints = 0;  // Variable to store total activity points
  bool _showHint = true;    // Variable to control hint visibility
  bool _highlightStar = true; // Variable to control star highlight
  TextEditingController _searchController = TextEditingController(); // Controller for search bar
  String _searchQuery = ""; // Search query string

  @override
  void initState() {
    super.initState();
    // Delay the hint disappearance after a few seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showHint = false;
        _highlightStar = false; // Stop highlighting the star after hint disappears
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Events',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Registered Events'),
              Tab(text: 'Attended Events'),
            ],
          ),
          backgroundColor: Colors.white,
          actions: [
            Tooltip(
              message: 'View your activity points',
              child: IconButton(
                icon: Icon(
                  Icons.star,
                  color: _highlightStar ? Colors.orange : Colors.black, // Highlight star icon
                  size: _highlightStar ? 30 : 24, // Increase size while highlighted
                ),
                onPressed: () {
                  _showActivityPoints(context);
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.grey, // Border color when not focused
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.black, // Border color when focused
                        ),
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query.toLowerCase();
                      });
                    },
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      _buildEventList(currentUserId, 'pending'),
                      _buildEventList(currentUserId, 'YES'),
                    ],
                  ),
                ),
              ],
            ),
            if (_showHint)
              Positioned(
                top: 1,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.star, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Tap the star icon to view your activity points',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(String? userId, String status) {
    final eventStream = FirebaseFirestore.instance
        .collection('REGISTRATIONS')
        .where('userId', isEqualTo: userId)
        .where('ScannedStatus', isEqualTo: status)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No events found'));
        }

        final registrationDocs = snapshot.data!.docs;
        _activityPoints = 0;  // Reset activity points

        // Filter the events based on the search query
        final filteredDocs = registrationDocs.where((registrationDoc) {
          final eventId = registrationDoc['eventId'];
          final eventData = FirebaseFirestore.instance.collection('EVENTS').doc(eventId).get().then((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final eventName = data['eventName'] ?? 'No Title';
            return eventName.toLowerCase().contains(_searchQuery);
          });
          return eventData != null; // Only include events that match the search query
        }).toList();

        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final registrationDoc = filteredDocs[index];
            final eventId = registrationDoc['eventId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('EVENTS')
                  .doc(eventId)
                  .get(),
              builder: (context, eventSnapshot) {
                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }

                if (!eventSnapshot.hasData || eventSnapshot.data == null) {
                  return const ListTile(
                    title: Text('Event not found'),
                  );
                }

                final eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
                final eventLevel = eventData['eventLevel'] ?? '';

                // Calculate activity points
                if (registrationDoc['ScannedStatus'] == 'YES') {
                  _activityPoints += _getPointsForLevel(eventLevel);
                }

                return Card(
                  color: Colors.black87,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${eventData['eventName'] ?? 'No Title'}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.event, color: Colors.white), // Event date icon
                            const SizedBox(width: 5),
                            Text(
                              'Date: ${eventData['eventDate'] ?? 'No Date'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.place, color: Colors.white), // Location icon
                            const SizedBox(width: 5),
                            Text(
                              'Location: ${eventData['eventLocation'] ?? 'No Location'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.white), // Price icon
                            const SizedBox(width: 5),
                            Text(
                              'Price: ${eventData['eventPrice'] ?? 'No Price'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.military_tech, color: Colors.white), // Event level icon
                            const SizedBox(width: 5),
                            Text(
                              'Level: $eventLevel',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to the EventDetails page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetails(eventKey: eventId),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info, color: Colors.black),
                            label: const Text('View Details', style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _getPointsForLevel(String eventLevel) {
    switch (eventLevel) {
      case 'Level I':
        return 6;
      case 'Level II':
        return 15;
      case 'Level III':
        return 20;
      case 'Level IV':
        return 30;
      case 'Level V':
        return 50;
      default:
        return 0;
    }
  }

  void _showActivityPoints(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_sharp, color: Colors.orange, size: 50),
              const SizedBox(height: 10),
              const Text(
                'Your Activity Points',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$_activityPoints Points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
