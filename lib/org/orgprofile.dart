import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/loginpage.dart';
import 'package:universe2024/org/editdetails.dart';

class OrgProfile extends StatefulWidget {
  const OrgProfile({Key? key}) : super(key: key);

  @override
  State<OrgProfile> createState() => _OrgProfileState();
}

class _OrgProfileState extends State<OrgProfile> {
  late Stream<DocumentSnapshot> _userStream;
  late Stream<List<Map<String, dynamic>>> _eventsStream;
  late Stream<List<Map<String, dynamic>>> _allEventsStream;

  @override
  void initState() {
    super.initState();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots();
    _eventsStream = _fetchAllEvents(currentUserUid);
    _allEventsStream = _fetchAllUsersEvents();
  }

  Stream<List<Map<String, dynamic>>> _fetchAllEvents(String? userId) async* {
    if (userId == null) {
      yield [];
      return;
    }
    final now = DateTime.now();

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .where('eventDate', isGreaterThanOrEqualTo: now)
        .orderBy('eventDate')
        .get();

    final events = eventsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'eventName': data['eventName'],
        'eventDate': (data['eventDate'] as Timestamp).toDate(),
        'eventLocation': data['eventLocation'],
        'eventPrice': data['eventPrice'],
        'eventType': data['eventType'],
        'documentID': doc.id,
      };
    }).toList();

    yield events;
  }

  Stream<List<Map<String, dynamic>>> _fetchAllUsersEvents() async* {
    final usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> allEvents = [];

    for (final userDoc in usersSnapshot.docs) {
      final eventsSnapshot = await userDoc.reference.collection('events').get();
      final userEvents = eventsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'eventName': data['eventName'],
          'eventDate': (data['eventDate'] as Timestamp).toDate(),
          'eventLocation': data['eventLocation'],
          'eventPrice': data['eventPrice'],
          'eventType': data['eventType'],
          'documentID': doc.id,
        };
      }).toList();

      allEvents.addAll(userEvents);
    }

    yield allEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Community Profile',
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
        physics: AlwaysScrollableScrollPhysics(),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final userData = userSnapshot.data?.data() as Map<String, dynamic>;
            final collegeName = userData['collegeName'] ?? '';
            final email = userData['email'] ?? '';
            final mobileNumber = userData['mobileNumber'] ?? '';
            final name = userData['name'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/ieeeprofile.jpeg'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '$name',
                        style: TextStyle(
                          color: Styles.blueColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note_alt_outlined, color: Styles.blueColor),
                          Gap(8),
                          Text(
                            'About us',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Styles.blueColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Styles.yellowColor),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Name: $name',
                              style: TextStyle(fontSize: 16, color: Styles.blueColor),
                            ),
                            Gap(5),
                            Text(
                              'Email: $email',
                              style: TextStyle(fontSize: 16, color: Styles.blueColor),
                            ),
                            Gap(5),
                            Text(
                              'Phone Number: $mobileNumber',
                              style: TextStyle(fontSize: 16, color: Styles.blueColor),
                            ),
                            Gap(5),
                            Text(
                              'College Name: $collegeName',
                              style: TextStyle(fontSize: 16, color: Styles.blueColor),
                            ),
                            Gap(10),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditDetailsForm(userData: userData),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Styles.blueColor,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Edit Details',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(100),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => loginpage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.blueColor,
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Gap(30),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
