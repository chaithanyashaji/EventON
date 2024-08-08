import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/org/addevent.dart';
import 'package:universe2024/org/attendee.dart';
import 'package:universe2024/org/qrscanner.dart';
import 'package:universe2024/pages/Eventdetails.dart';
import 'package:universe2024/pages/Userpage.dart';
import 'package:universe2024/pages/chatbot.dart';
import 'package:universe2024/org/orgprofile.dart';
import 'package:universe2024/pages/qrcode.dart';
import 'package:universe2024/pages/search1.dart';


class SocHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<SocHomePage> {
  int _selectedIndex = 0;
  late Stream<List<Map<String, dynamic>>> _stream;

  static List<Widget> _widgetOptions = <Widget>[
    searchpage1(),
    attendee(),
    addevent(),
    OrgProfile()
  ];

  @override
  void initState() {
    super.initState();
    _stream = _fetchEvents();
  }

  Stream<List<Map<String, dynamic>>> _fetchEvents() async* {
    try {
      // Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      final userDocs = usersSnapshot.docs;

      final events = <Map<String, dynamic>>[];

      for (final userDoc in userDocs) {
        final eventsSnapshot =
            await userDoc.reference.collection('events').get();
        final eventDocs = eventsSnapshot.docs;

        for (final eventDoc in eventDocs) {
          events.add({
            'eventName': eventDoc['eventName'],
            'eventDate': eventDoc['eventDate'],
            'eventLocation': eventDoc['eventLocation'],
            'eventPrice': eventDoc['eventPrice'],
            'eventtype': eventDoc['eventtype'],
            'documentID': eventDoc.id, // Add the document ID here
          });
        }
      }

      yield events;
    } catch (e) {
      print('Error fetching events: $e');
      yield []; // Return an empty list if an error occurs
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index != 5) {
        _selectedIndex = index;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => searchpage1()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Some error occurred'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                final items = snapshot.data!;
                return HomeContent(items: items);
              }
              return Center(child: Text('No events available'));
            },
          ),
          _widgetOptions.elementAt(_selectedIndex),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_3),
            label: 'Registrants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Styles.blueColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => chat()),
          );
        },
        child: Icon(Icons.chat, color: Styles.blueColor),
        backgroundColor: Styles.yellowColor,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const HomeContent({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(20, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.yellowColor,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-2.7, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.blueColor,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(2.7, -1.2),
                child: Container(
                  height: MediaQuery.of(context).size.width / 1.3,
                  width: MediaQuery.of(context).size.width / 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Styles.lblueColor,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                child: Container(),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(),
            child: Column(
              children: [
                Image.asset(
                  'assets/logowhite.png',
                  width: 200,
                  height: 100,
                ),
                Text(
                  "UniVerse",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Events",
                        style: TextStyle(
                          fontSize: 21.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(10),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 200,
                              child: Card(
                                elevation: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/3.jpeg',
                                      height: 135,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Event ${index + 1}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Events",
                        style: TextStyle(
                          fontSize: 21.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Gap(10),
                      SizedBox(
                        height: 325,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> event = items[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 220,
                              child: Card(
                                elevation: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/13.jpg',
                                            height: 135,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            event['eventName'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Date: ${event['eventDate']}\nEvent Type: ${event['eventtype']}\nPrice: ${event['eventPrice']}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventDetails(
                                                eventKey: event['documentID']),
                                          ),
                                        );
                                      },
                                      child: Text('Register',
                                          style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SocHomePage(),
  ));
}
