import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EventDetails.dart'; // Import the EventDetails page

class RegisteredEvent extends StatelessWidget {
  const RegisteredEvent({super.key});

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

                  return ListTile(
                    title: Text(eventData['eventName'] ?? 'No Title'),
                    subtitle: Text(eventData['eventLocation'] ?? 'No Location'),
                    trailing: Text('Date: ${eventData['eventDate']}'),
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
      ),
    );
  }
}
