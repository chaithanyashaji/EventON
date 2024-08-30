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
  bool isSearchIconTapped = false;
  int _activityPoints = 0;  // Variable to store total activity points

  @override
  void initState() {
    super.initState();
    _fetchAndUpdateActivityPoints(); // Fetch and update activity points on initialization
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
            IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: isSearchIconTapped ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.search,
                  color: isSearchIconTapped ? Colors.black : Colors.white,
                ),
              ),
              onPressed: () {
                setState(() {
                  isSearchIconTapped = !isSearchIconTapped;
                });
                showSearch(
                  context: context,
                  delegate: RegisteredEventSearchDelegate(currentUserId),
                ).then((_) {
                  setState(() {
                    isSearchIconTapped = false;
                  });
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.orange), // Activity points icon
                  const SizedBox(width: 5),
                  Text(
                    'Total Activity Points: $_activityPoints',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
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

        return ListView.builder(
          itemCount: registrationDocs.length,
          itemBuilder: (context, index) {
            final registrationDoc = registrationDocs[index];
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
                final eventLevel = eventData['eventLevel'] ?? 'Level I';

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
                            color: Colors.white,
                          ),
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

  Future<void> _fetchAndUpdateActivityPoints() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Fetch user's current activity points from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final currentPoints = userDoc.data()?['activityPoints'] ?? 0;

    // Update Firestore with new activity points
    final updatedPoints = currentPoints + _activityPoints;
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'activityPoints': updatedPoints,
    }, SetOptions(merge: true));

    setState(() {
      _activityPoints = updatedPoints; // Update state with new activity points
    });
  }
}

// Define the RegisteredEventSearchDelegate outside the RegisteredEvent class
class RegisteredEventSearchDelegate extends SearchDelegate {
  final String? userId;

  RegisteredEventSearchDelegate(this.userId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _searchEvents();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _searchEvents();
  }

  Widget _searchEvents() {
    if (userId == null) {
      return const Center(child: Text('User not found'));
    }

    final eventStream = FirebaseFirestore.instance
        .collection('REGISTRATIONS')
        .where('userId', isEqualTo: userId)
        .where('ScannedStatus', isEqualTo: 'pending')
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

        return ListView.builder(
          itemCount: registrationDocs.length,
          itemBuilder: (context, index) {
            final registrationDoc = registrationDocs[index];
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

                return ListTile(
                  title: Text(eventData['eventName'] ?? 'No Title'),
                  subtitle: Text('Date: ${eventData['eventDate'] ?? 'No Date'}'),
                  onTap: () {
                    // Navigate to the EventDetails page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetails(eventKey: eventId),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
