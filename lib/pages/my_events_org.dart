import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/org/attendee.dart';

class MyEventsPage extends StatefulWidget {
  final String userId;

  MyEventsPage({required this.userId});

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  bool isSearchIconTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Events'),
        actions: [
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: isSearchIconTapped ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(8), // Rounded square background
              ),
              padding: EdgeInsets.all(8),
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
                delegate: EventSearchDelegate(widget.userId),
              ).then((_) {
                setState(() {
                  isSearchIconTapped = false;
                });
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('EVENTS')
              .where('addedBy', isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No events found.', style: TextStyle(color: Colors.black)));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var event = doc.data() as Map<String, dynamic>;

                return _buildEventCard(event, doc.id, index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, String docId, int index) {
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
              '${index + 1}. ${event['eventName']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'Date: ${event['eventDate']}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'Location: ${event['eventLocation']}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  'Price: ${event['eventPrice']}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Attendee(eventId: docId),
                    ),
                  );
                },
                icon: Icon(Icons.people, color: Colors.black), // Add icon here
                label: Text('View Registrants', style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 40), // Expand button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventSearchDelegate extends SearchDelegate {
  final String userId;

  EventSearchDelegate(this.userId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(child: Text('Enter event name to search'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('EVENTS')
          .where('addedBy', isEqualTo: userId)
          .where('eventName', isGreaterThanOrEqualTo: query)
          .where('eventName', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('eventName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No events found.', style: TextStyle(color: Colors.black)));
        }

        var events = snapshot.data!.docs;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            var doc = events[index];
            var event = doc.data() as Map<String, dynamic>;

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
                      '${index + 1}. ${event['eventName']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Date: ${event['eventDate']}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Location: ${event['eventLocation']}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Price: ${event['eventPrice']}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Attendee(eventId: doc.id),
                            ),
                          );
                        },
                        icon: Icon(Icons.people, color: Colors.black),
                        label: Text('View Registrants', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 40),
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
  }
}
