import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gap/gap.dart';

import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/loginpage.dart';

class profile extends StatefulWidget {
  const profile({Key? key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  late Stream<DocumentSnapshot> _stream;

  @override
  void initState() {
    super.initState();
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Styles.yellowColor,
                      Styles.lblueColor,
                      Styles.blueColor
                    ])),
          ),
          title: Text(
            'Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          leading: SizedBox(
            width: 800, // Set the desired width
            height: double.infinity,
            child: Image.asset(
              'assets/logowhite.png',
              fit: BoxFit.fitHeight, // Adjust the fit as needed
            ),
          ),
          backgroundColor: Styles.blueColor),

        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
    child: StreamBuilder<DocumentSnapshot>(
    stream: _stream,
    builder: (BuildContext context,
    AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.hasError) {
    return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    }

    final userData = snapshot.data?.data() as Map<String, dynamic>;
    final name = userData['name'] ?? '';
    final email = userData['email'] ?? '';
    final phoneNumber = userData['phoneNumber'] ?? '';
    final collegeName = userData['collegeName'] ?? '';
            return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: SingleChildScrollView(
                              child: Column(children: [
                                const Gap(20),
                                Icon(
                                  Icons.person,
                                  size: 90,
                                  color: Styles.blueColor,
                                ),
                                const Gap(10),
                                Text(
                                  "$name",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Styles.blueColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(50),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin:
                                            const EdgeInsets.only(left: 27.0),
                                            // Adjust the left margin as needed
                                            child: Icon(
                                              Icons.note_alt_outlined,
                                              color: Styles.blueColor,
                                            ),
                                          ),
                                          Gap(3),
                                          Text(
                                            'About me',
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
                                        margin:
                                        const EdgeInsets.only(left: 24.0,right: 24),
                                        width: 450,
                                        height: 210,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Styles.yellowColor),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            'Name  :  $name',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Styles
                                                                    .blueColor),
                                                          ),
                                                          Gap(5),
                                                          Text(
                                                            'Email  :  $email',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Styles
                                                                    .blueColor),
                                                          ),
                                                          Gap(5),
                                                          Text(
                                                            'Phone Number  : $phoneNumber',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Styles
                                                                    .blueColor),
                                                          ),
                                                          Gap(5),
                                                          Text(
                                                            'College Name  :  $collegeName',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Styles
                                                                    .blueColor),
                                                          ),
                                                        ])
                                                  ]),
                                              const Gap(12),
                                              Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.center,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          // Call function to pick image
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.add,color: Styles.blueColor,),
                                                            Text('Edit Details',style: TextStyle
                                                              (color: Styles.blueColor,fontWeight: FontWeight.w600),),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                Gap(50),
                                Gap(30),
                                Container(
                                  width: 150,
                                  height: 40,
                                  child: Material(
                                      elevation: 8,
                                      // Adjust the elevation as needed
                                      borderRadius: BorderRadius.circular(25),
                                      // Set the same border radius as the button
                                      child: SizedBox(
                                        // Adjust the width here
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate to the signup page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      loginpage()),
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
                                      )),
                                ),
                                Gap(30),
                              ]))))
                ],
    ),
            );
    },
    ),
        ),
    );
  }
}