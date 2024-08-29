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

  @override
  Widget build(BuildContext context) {
    // Getting the current user ID from FirebaseAuth
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Querying the REGISTRATIONS collection where userid is equal to currentUserId
    final registrationsStream = FirebaseFirestore.instance
        .collection('REGISTRATIONS')
        .where('userId', isEqualTo: currentUserId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Events'),
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: isSearchIconTapped ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(8), // Rounded square background
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
      body: StreamBuilder<QuerySnapshot>(
        stream: registrationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No registered events found'));
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
                              const Icon(Icons.calendar_today, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'Date: ${eventData['eventDate'] ?? 'No Date'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'Location: ${eventData['eventLocation'] ?? 'No Location'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: Colors.white),
                              const SizedBox(width: 5),
                              Text(
                                'Price: ${eventData['eventPrice'] ?? 'No Price'}',
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
                                minimumSize: const Size(double.infinity, 40), // Expand button
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
      ),
    );
  }
}

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
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter event name to search'));
    }

    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('REGISTRATIONS')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No events found.'));
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

                // Check if the event name matches the query
                if (!eventData['eventName'].toString().toLowerCase().contains(query.toLowerCase())) {
                  return Container(); // Return an empty container if no match
                }

                return Card(
                  color: Colors.black,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${eventData['eventName']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Date: ${eventData['eventDate']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Location: ${eventData['eventLocation']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              'Price: ${eventData['eventPrice']}',
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
                              minimumSize: const Size(double.infinity, 40), // Expand button
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
}
