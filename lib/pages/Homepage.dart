import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/pages/Eventdetails.dart';
import 'package:universe2024/pages/chatbot.dart';
import 'package:universe2024/pages/search.dart';
import 'package:universe2024/pages/search1.dart';
import 'package:universe2024/pages/profile.dart';
import 'package:universe2024/pages/my_events.dart';
import 'package:universe2024/pages/notifications.dart'; // Import the Notifications page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  CollectionReference _reference = FirebaseFirestore.instance.collection('EVENTS');

  late Stream<QuerySnapshot> _stream;

  static List<Widget> _widgetOptions = <Widget>[
    searchpage1(),
    searchpage(),
    MyEventsPage(),
    Profile(),// Add My Events page to the widget options
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _stream = _reference.snapshots();
    return Scaffold(
      backgroundColor: Colors.white, // Set the entire background color to white
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar background color
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          SizedBox(width: 10), // Spacing between icons
          Image.asset('assets/EventOn.png', height: 32), // Adjust height as needed
          SizedBox(width: 10), // Spacing between icons
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Some error'));
              }
              if (snapshot.hasData) {
                QuerySnapshot querySnapshot = snapshot.data!;
                List<QueryDocumentSnapshot> documents = querySnapshot.docs;

                List<Map> items = documents.map((e) {
                  return {
                    'eventName': e['eventName'],
                    'eventDate': e['eventDate'],
                    'eventLocation': e['eventLocation'],
                    'eventPrice': e['eventPrice'],
                    'eventType': e['eventType'],
                    'documentID': e.id, // Capture the document ID
                  };
                }).toList();

                return HomeContent(items: items);
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
          if (_selectedIndex != 0) _widgetOptions.elementAt(_selectedIndex),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Left and right margin
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30), // Curved edges
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // Ensure the bar is curved
          child: BottomNavigationBar(
            backgroundColor: Colors.black, // Set background color to black
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
                icon: _buildIcon(Icons.event, 2),
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
        child: Icon(Icons.chat, color: Colors.white), // White messaging icon
        backgroundColor: Colors.black, // Black background
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white), // White border around icons
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
  final List<Map> items;

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
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // White background for the container
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
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 0,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                                  child: Image.asset(
                                    'assets/3.jpeg',
                                    height: 210,
                                    width: 210, // Ensure width matches height to maintain aspect ratio
                                    fit: BoxFit.cover, // Adjusts the image to cover the container
                                  ),
                                ),

                                Gap(5),
                                Text('Event ${index + 1}', style: TextStyle(fontSize: 18)),
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
                margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
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
                          Map event = items[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 220, // Constrained width for each card
                            child: Card(
                              color: Colors.grey[80], // Background color for the card
                              elevation: 5, // Add shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15), // Curved edges for the image
                                          child: Image.asset(
                                            'assets/13.jpg',
                                            height: 160, // Increased height for the image
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
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
                                        minimumSize: Size(double.infinity, 50), // Full width button with a fixed height
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15), // Rounded corners for the button
                                        ),
                                      ),
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white, // White text color
                                        ),
                                      ),
                                    ),
                                  )
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
