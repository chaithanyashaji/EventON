import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/pages/search.dart';

class HomePage1 extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage1> {
  int _selectedIndex = 0;
  CollectionReference _reference =
      FirebaseFirestore.instance.collection('event');

  late Stream<QuerySnapshot> _stream;

  void _onItemTapped(int index) {
    setState(() {
      if (index != 5) {
        _selectedIndex = index;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => searchpage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _stream = _reference.snapshots();
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: StreamBuilder<QuerySnapshot>(
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
                  'name': e['name'],
                  'date': e['date'],
                  'location': e['location'],
                  'price': e['price'],
                };
              }).toList();

              return HomeContent(items: items);
            }
            return Center(child: CircularProgressIndicator());
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
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
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotPage()),
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Styles.blueColor,
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
      physics: BouncingScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
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
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Gap(10),
                                  // Add posters and event names here
                                  SizedBox(
                                    height: 200, // Adjust poster height
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 5, // Example itemCount
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'assets/123.jpg',
                                                height: 150,
                                              ),
                                              Text('Event ${index + 1}'),
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
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Gap(10),
                                  // Add registration cards with posters for upcoming events here
                                  SizedBox(
                                    height: 300, // Adjust card height
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        Map event = items[index];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          width: 200, // Adjust card width
                                          child: Card(
                                            elevation: 3,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        'assets/123.jpg',
                                                        height: 100,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        event['name'],
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        'Date: ${event['date']}\nLocation: ${event['location']}\nPrice: ${event['price']}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RegisterPage(),
                                                      ),
                                                    );
                                                  },
                                                  child: Text('Register'),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Text('Register Page Content'),
      ),
    );
  }
}

class ChatbotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Center(
        child: Text('Chatbot Page Content'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Page Content'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage1(),
  ));
}
