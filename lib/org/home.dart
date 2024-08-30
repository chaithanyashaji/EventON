import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/admin/approval.dart';
import 'package:universe2024/org/addevent.dart';
import 'package:universe2024/org/attendee.dart';
import 'package:universe2024/org/payment_approval.dart';
import 'package:universe2024/org/qrscanner.dart';
import 'package:universe2024/pages/Eventdetails.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/Userpage.dart';
import 'package:universe2024/pages/chatbot.dart';
import 'package:universe2024/org/orgprofile.dart';
import 'package:universe2024/org/my_events_org.dart';

import 'package:universe2024/pages/qrcode.dart';
import 'package:universe2024/pages/search1.dart';

import '../pages/loginpage.dart';


class SocHomePage extends StatefulWidget {
  final String userId;

  SocHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _SocHomePageState createState() => _SocHomePageState();
}

class _SocHomePageState extends State<SocHomePage> {
  int _selectedIndex = 0;
  late Stream<List<Map<String, dynamic>>> _stream;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _setupStream();
    _widgetOptions = <Widget>[
      searchpage1(),
      MyEventsPage(userId: widget.userId),
      AddEvent(userID: widget.userId),
      PayApprovalsPage(userId: widget.userId,),
      OrgProfile(),
      // Add other widget options here if needed
    ];
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
          'eventType': eventDoc['eventType'],
          'imageUrl': eventDoc['imageUrl'], // Fetch the imageUrl field
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
        automaticallyImplyLeading: false,
        actions: [

          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              _showLogoutConfirmation(context);
            },
            child: Image.asset('assets/EventOn.png', height: 32),
          ),
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
                icon: _buildIcon(Icons.event_available, 1),
                label: 'Registrants',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.add, 2),
                label: 'Add Events',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.admin_panel_settings, 3),
                label: 'Approval',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.person, 4),
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
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.black, // Set the dialog background to black
            textTheme: TextTheme(
              titleLarge: TextStyle(color: Colors.white), // Set title text to white
              bodyLarge: TextStyle(color: Colors.white),  // Set content text to white
            ),
          ),
          child: AlertDialog(
            title: Text('Logout', style: TextStyle(color: Colors.white)), // Set title color to white
            content: Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white)), // Set content color to white
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)), // Set button text color to white
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  _logout(); // Call the logout function
                },
                child: Text('Logout', style: TextStyle(color: Colors.white)), // Set button text color to white
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginpage()),
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
                      Map<String, dynamic> event = items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  event['imageUrl'], // Use the imageUrl from Firestore
                                  height: 210,
                                  width: 210,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            Gap(5),
                            Text(
                              event['eventName'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
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
              color: Colors.white,
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
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> event = items[index];
                      return Container(
                        width: 220,
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  event['imageUrl'], // Use the imageUrl from Firestore
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                event['eventName'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.black),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Date: ${event['eventDate']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.category, size: 16, color: Colors.black),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Type: ${event['eventType']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_money, size: 16, color: Colors.black),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Price: ${event['eventPrice']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EventDetails(eventKey: event['documentID']),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize: Size(double.infinity, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
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
    );
  }
}
