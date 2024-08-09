import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/loginpage.dart';
import 'package:universe2024/org/editdetails.dart'; // Import the new form

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns children to the ends
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
                SizedBox(
                  height: 350,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25)),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/ieeebanner.jpeg'),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 115,
                        left: 120,
                        child: Container(
                          width: 300,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Styles.yellowColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$name',
                              style: TextStyle(
                                  color: Styles.blueColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 90,
                        left: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Styles.yellowColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                            AssetImage('assets/ieeeprofile.jpeg'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 27.0),
                              child: Icon(
                                Icons.note_alt_outlined,
                                color: Styles.blueColor,
                              ),
                            ),
                            Gap(3),
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
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.only(left: 27.0),
                        width: 450,
                        decoration: BoxDecoration(
                          border:
                          Border.all(width: 1, color: Styles.yellowColor),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Community Name  :  $name',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Styles.blueColor,
                                        ),
                                      ),
                                      Gap(5),
                                      Text(
                                        'Email  :  $email',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Styles.blueColor,
                                        ),
                                      ),
                                      Gap(5),
                                      Text(
                                        'Phone Number  : $mobileNumber',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Styles.blueColor,
                                        ),
                                      ),
                                      Gap(5),
                                      Text(
                                        'College Name  :  $collegeName',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Styles.blueColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditDetailsForm(userData: userData),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add,
                                              color: Styles.blueColor),
                                          Text(
                                            'Edit Details',
                                            style: TextStyle(
                                              color: Styles.blueColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(30),
                      Container(
                        margin: const EdgeInsets.only(left: 29.0),
                        child: Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Styles.blueColor,
                          ),
                        ),
                      ),
                      Gap(10),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _eventsStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                            eventSnapshot) {
                          if (eventSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${eventSnapshot.error}'));
                          }
                          if (eventSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final events = eventSnapshot.data ?? [];
                          return Container(
                            margin: const EdgeInsets.only(left: 27.0),
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Styles.yellowColor),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    width: 200,
                                    child: Card(
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 15,
                                          bottom: 15),
                                      elevation: 3,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Image.asset('assets/12.jpg',
                                                    height: 125),
                                                const SizedBox(height: 10),
                                                Text(
                                                  event['eventName'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Date: ${event['eventDate']}\nLocation: ${event['eventLocation']}\nPrice: ${event['eventPrice']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Gap(30),
                      Container(
                        margin: const EdgeInsets.only(left: 29.0),
                        child: Text(
                          'All Events',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Styles.blueColor,
                          ),
                        ),
                      ),
                      Gap(10),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _allEventsStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                            allEventsSnapshot) {
                          if (allEventsSnapshot.hasError) {
                            return Center(
                                child:
                                Text('Error: ${allEventsSnapshot.error}'));
                          }
                          if (allEventsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final allEvents = allEventsSnapshot.data ?? [];
                          return Container(
                            margin: const EdgeInsets.only(left: 27.0),
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: Styles.yellowColor),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: allEvents.length,
                                itemBuilder: (context, index) {
                                  final event = allEvents[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    width: 200,
                                    child: Card(
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 15,
                                          bottom: 15),
                                      elevation: 3,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Image.asset('assets/3.jpeg',
                                                    height: 125),
                                                const SizedBox(height: 10),
                                                Text(
                                                  event['eventName'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Date: ${event['eventDate']}\nLocation: ${event['eventLocation']}\nPrice: ${event['eventPrice']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Gap(30),
                      Center(
                        child: Container(
                          width: 150,
                          height: 40,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(25),
                            child: SizedBox(
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
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
