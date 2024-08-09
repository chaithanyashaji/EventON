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

class Admhome extends StatefulWidget {
  @override
  _AdmhomeState createState() => _AdmhomeState();
}

class _AdmhomeState extends State<Admhome> {
  int _selectedIndex = 0;
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _registrationWebsiteController = TextEditingController();

  late Stream<List<Map<String, dynamic>>> _stream;

  static List<Widget> _widgetOptions = <Widget>[
    Admaddevent(),
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

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.bgColor,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Approvals',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Styles.blueColor,
        onTap: _onItemTapped,
      ),
    );
  }

  
}
