import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/admin/admaddevent.dart';
import 'package:universe2024/admin/approval.dart';
import 'package:universe2024/pages/search1.dart';
import 'package:universe2024/org/attendee.dart';
import 'package:universe2024/org/orgprofile.dart';
import 'package:universe2024/pages/chatbot.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/loginpage.dart';

class Admhome extends StatefulWidget {
  final String userId;

  const Admhome({super.key, required this.userId});

  @override
  _AdmhomeState createState() => _AdmhomeState();
}

class _AdmhomeState extends State<Admhome> {
  int _selectedIndex = 0;
  late Stream<List<Map<String, dynamic>>> _stream;


  static List<Widget> _widgetOptions = <Widget>[
    AdmAddEvent(),
    ApprovalsPage(), // Widget for user approvals
  ];


  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    _stream = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .asyncMap((usersSnapshot) async {
      List<Map<String, dynamic>> allUsers = [];

      for (var userDoc in usersSnapshot.docs) {
        allUsers.add({
          'id': userDoc.id,
          'name': userDoc['name'],
          'email': userDoc['email'],
          // Assuming a 'status' field for users
        });
      }

      return allUsers;
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
    // Dynamically build widget options
    List<Widget> _widgetOptions = [
      Admaddevent(userID: widget.userId),
      ApprovalsPage(), // Widget for user approvals
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          SizedBox(width: 10),
          GestureDetector(
            onTap: _logout,
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
                // Display user data or any other content here
                return Center(child: Text(''));
              }
              return Center(child: Text('No data available'));
            },
          ),
          _widgetOptions[_selectedIndex], // Show form when Home tab is selected
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
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon(Icons.admin_panel_settings, 1),
                label: 'Approvals',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
          ),
        ),
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
