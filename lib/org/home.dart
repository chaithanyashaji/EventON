import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/org/addevent.dart';
import 'package:universe2024/org/attendee.dart';
import 'package:universe2024/org/qrscanner.dart';
import 'package:universe2024/pages/Eventdetails.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/Userpage.dart';
import 'package:universe2024/pages/chatbot.dart';
import 'package:universe2024/org/orgprofile.dart';
import 'package:universe2024/pages/qrcode.dart';
import 'package:universe2024/pages/search1.dart';

class SocHomePage extends StatefulWidget {
  final String userId;

  SocHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _SocHomePageState createState() => _SocHomePageState();
}

class _SocHomePageState extends State<SocHomePage> {
  int _selectedIndex = 0;
  late Stream<List<Map<String, dynamic>>> _stream;

  static List<Widget> _widgetOptions = <Widget>[
    searchpage1(),
    attendee(),
    AddEvent(userID: ''),
    OrgProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    _stream = FirebaseFirestore.instance
        .collection('EVENTS')
        .snapshots()
        .map((eventsSnapshot) {
      List<Map<String, dynamic>> allEvents = [];

      for (var eventDoc in eventsSnapshot.docs) {
        allEvents.add({
          'eventName': eventDoc['eventName'],
          'eventDate': eventDoc['eventDate'],
          'eventLocation': eventDoc['eventLocation'],
          'eventPrice': eventDoc['eventPrice'],
          'documentID': eventDoc.id,
        });
      }

      return allEvents;
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Add your notification navigation here
            },
          ),
          SizedBox(width: 10),
          Image.asset('assets/EventOn.png', height: 32),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Some error occurred: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                List<Map<String, dynamic>> items = snapshot.data!;

                return HomeContent(items: items);
              }
              return Center(child: Text('No events available'));
            },
          ),
          if (_selectedIndex != 0) _widgetOptions.elementAt(_selectedIndex),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.person_3, 1),
                label: 'Registrants',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.add, 2),
                label: 'Add Events',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.person, 3),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.transparent,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onItemTapped,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat()),
          );
        },
        child: Icon(Icons.chat, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        shape: BoxShape.circle,
        color: _selectedIndex == index ? Colors.white : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: _selectedIndex == index ? Colors.black : Colors.white,
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
      child: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Container(
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
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black, width: 2), // Black border with width of 2
                                    borderRadius: BorderRadius.circular(15), // Same radius as ClipRRect
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/3.jpeg',
                                      height: 210,
                                      width: 210,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Gap(5),
                                Text('Event ${index + 1}', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the Upcoming Events container
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upcoming Events",
                      style: TextStyle(
                        fontSize: 21.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black text color
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
                            width: 220, // Constrained width for each card
                            child: Card(
                              color: Colors.white, // Light grey background for the card
                              elevation: 5, // Add shadow
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black,width: 1.5),
                                borderRadius: BorderRadius.circular(15),

                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15), // Curved edges for the image
                                    child: Image.asset(
                                      'assets/13.jpg',
                                      height: 160, // Height for the image
                                      width: double.infinity, // Ensure image takes full width
                                      fit: BoxFit.cover, // Ensure image fits within the constraints
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    event['eventName'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold, // Bold event name
                                      color: Colors.black, // Black text color
                                    ),
                                    maxLines: 1, // Limit event name to one line
                                    overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                    textAlign: TextAlign.center, // Center align the event name
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Date: ${event['eventDate']}\nEvent Type: ${event['eventtype']}\nPrice: ${event['eventPrice']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black, // Black text color
                                    ),
                                    maxLines: 2, // Limit to two lines if necessary
                                    overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                    textAlign: TextAlign.center, // Center align the event details
                                  ),
                                  Spacer(), // Pushes the button to the bottom of the card
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventDetails(eventKey: event['documentID']),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black, // Black background for the button
                                        minimumSize: Size(double.infinity, 40), // Adjusted button size to avoid overflow
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15), // Rounded corners for the button
                                        ),
                                      ),
                                      child: Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white, // White text color
                                        ),
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}
