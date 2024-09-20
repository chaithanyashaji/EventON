import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:EventON/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:EventON/org/orgprofile.dart';
import 'package:EventON/pages/Eventdetails.dart';
import 'package:EventON/pages/chatbot.dart';
import 'package:EventON/pages/my_events_user.dart';
import 'package:EventON/pages/search.dart';
import 'package:EventON/pages/search1.dart';
import 'package:EventON/pages/profile.dart';
import 'package:EventON/org/my_events_org.dart';
import 'package:EventON/pages/notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'loginpage.dart';

class HomePage extends StatefulWidget {
  final String userId;
  HomePage({Key? key, required this.userId}) : super(key: key);




  @override
  _HomePageState createState() => _HomePageState();

}



class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  CollectionReference _reference = FirebaseFirestore.instance.collection('EVENTS');

  late Stream<List<Map<String, dynamic>>> _eventsStream;
  late Stream<List<Map<String, dynamic>>> _adminEventsStream;

  static List<Widget> _widgetOptions = <Widget>[
    searchpage1(),
    SearchPage(),
    RegisteredEvent(),
    Profile()
  ];

  @override
  void initState() {
    super.initState();
    _setupStreams();  // Ensure streams are set up
  }


  void _setupStreams() {
    _eventsStream = FirebaseFirestore.instance
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
          'imageUrl': eventDoc['imageUrl'],
          'documentID': eventDoc.id,
        });
      }

      return allEvents;
    });

    _adminEventsStream = FirebaseFirestore.instance
        .collection('adminEvents')
        .snapshots()
        .map((eventsSnapshot) {
      List<Map<String, dynamic>> adminEvents = [];

      for (var eventDoc in eventsSnapshot.docs) {
        adminEvents.add({
          'eventName': eventDoc['eventName'],
          'eventDate': eventDoc['eventDate'],
          'eventTime': eventDoc['eventTime'],
          'eventLocation': eventDoc['eventLocation'],
          'eventContact': eventDoc['eventContact'],
          'imageUrl': eventDoc['imageUrl'],
          'registrationLink': eventDoc['registrationLink'],
        });
      }
      return adminEvents;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => loginpage()),
    );
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
      body: _selectedIndex == 0
          ? Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _eventsStream,
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> eventsSnapshot) {
              if (eventsSnapshot.hasError) {
                return Center(child: Text('Some error occurred: ${eventsSnapshot.error}'));
              }
              if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _adminEventsStream,
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> adminEventsSnapshot) {
                  if (adminEventsSnapshot.hasError) {
                    return Center(child: Text('Some error occurred: ${adminEventsSnapshot.error}'));
                  }
                  if (adminEventsSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (eventsSnapshot.hasData && adminEventsSnapshot.hasData) {
                    List<Map<String, dynamic>> events = eventsSnapshot.data!;
                    List<Map<String, dynamic>> adminEvents = adminEventsSnapshot.data!;
                    return HomeContent(
                      events: events,
                      adminEvents: adminEvents,
                    );
                  }

                  return Center(child: Text('No events available'));
                },
              );
            },
          ),
        ],
      )
          : _widgetOptions.elementAt(_selectedIndex),

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
                icon: _buildIcon(Icons.search, 1),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.event_available, 2),
                label: 'My Events',
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
            selectedFontSize: 14,
            unselectedFontSize: 14,
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
            dialogBackgroundColor: Colors.black,
            textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white),
              bodyText2: TextStyle(color: Colors.white),
            ),
          ),
          child: AlertDialog(
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            content: Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
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
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> adminEvents;

  const HomeContent({
    Key? key,
    required this.events,
    required this.adminEvents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Events Section (without Black Border)
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
                    color: Colors.black, // Black text
                  ),
                ),
                const Gap(10),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: adminEvents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> adminEvent = adminEvents[index];
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              debugPrint("Event tapped!");
                              _showEventDetails(
                                context,
                                adminEvent['eventDate'],
                                adminEvent['registrationLink'],
                                adminEvent['eventContact'],
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        adminEvent['imageUrl'],
                                        height: 210,
                                        width: 210,
                                        fit: BoxFit.cover,
                                        color: Colors.black.withOpacity(0.2),
                                        colorBlendMode: BlendMode.darken,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.error, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    adminEvent['eventName'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                _launchURL(adminEvent['registrationLink']);
                              },
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black, // Black background for the CircleAvatar
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2), // White border
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5), // White shadow
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 0), // Shadow position
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.link,
                                    color: Colors.white, // White icon
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> event = events[index];
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
                                        builder: (context) => EventDetails(eventKey: event['documentID']),
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
  void _showEventDetails(
      BuildContext context,
      Timestamp eventDate,
      String registrationLink,
      String eventContact,
      ) {
    // Convert Timestamp to DateTime
    DateTime dateTime = eventDate.toDate();

    // Format DateTime to String (for example, 'dd/MM/yyyy')
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Transparent to allow the glass effect
      builder: (BuildContext bc) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Frosted glass effect
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7), // Semi-transparent black background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 20), // Event date icon
                    SizedBox(width: 10),
                    // Display the formatted date
                    Text(
                      "Deadline: $formattedDate", // Fixed to show the formatted date
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.link, color: Colors.white, size: 20), // Registration link icon
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "Registration: $registrationLink", // Long text handled
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis, // Handle long links
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.white, size: 20), // Event contact icon
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        "Contact: $eventContact", // Prevent overflow for event contact
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis, // Handle long text
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _launchURL(String url) async {
    Uri uri = Uri.parse(url); // Convert to Uri
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
