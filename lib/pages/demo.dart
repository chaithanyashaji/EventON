import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/pages/loginpage.dart';

class prof extends StatefulWidget {
  const prof({super.key});

  @override
  State<prof> createState() => _profState();
}

class _profState extends State<prof> {
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
              colors: [Styles.yellowColor, Styles.lblueColor, Styles.blueColor],
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: SizedBox(
          width: 800, // Set the desired width
          height: double.infinity,
          child: Image.asset(
            'assets/logowhite.png',
            fit: BoxFit.fitHeight, // Adjust the fit as needed
          ),
        ),
        backgroundColor: Styles.blueColor,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
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

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    Icon(
                      Icons.person,
                      size: 120,
                      color: Styles.blueColor,
                    ),
                    const Gap(10),
                    Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 25,
                        color: Styles.blueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: $name',
                          style: TextStyle(
                            fontSize: 16,
                            color: Styles.blueColor,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          'Email: $email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Styles.blueColor,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          'Phone Number: $phoneNumber',
                          style: TextStyle(
                            fontSize: 16,
                            color: Styles.blueColor,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          'College Name: $collegeName',
                          style: TextStyle(
                            fontSize: 16,
                            color: Styles.blueColor,
                          ),
                        ),
                        const Gap(20),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the edit profile page
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            backgroundColor: Styles.blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                              vertical: 10.0,
                            ),
                            child: Text(
                              'Edit Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(50),
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // Sign out the user
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => loginpage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          backgroundColor: Styles.blueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Gap(30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}