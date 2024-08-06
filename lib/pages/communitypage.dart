import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';

class CommunityPage extends StatefulWidget {
  final String communityId; // Add communityId parameter to the constructor

  const CommunityPage({Key? key, required this.communityId}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isFollowed = false;
  late String communityName = "";
  late String communityEmail = "";
  late String communityPhone = "";
  late String communityCollege = "";

  @override
  void initState() {
    super.initState();
    fetchCommunityDetails();
  }

  void toggleFollow() {
    setState(() {
      isFollowed = !isFollowed;
    });
  }

  void fetchCommunityDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.communityId) // Use the communityId passed from previous page
          .get();

      setState(() {
        communityName = documentSnapshot['name'];
        communityEmail = documentSnapshot['email']; // Adjust with your field names
        communityPhone = documentSnapshot['mobileNumber']; // Adjust with your field names
        communityCollege = documentSnapshot['collegeName']; // Adjust with your field names
      });
    } catch (e) {
      setState(() {
        communityName = "Error loading community name";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/ieeebanner.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 115,
                    left: 120,
                    child: Container(
                      width: 300,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Styles.yellowColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          communityName,
                          style: TextStyle(
                            color: Styles.blueColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 90,
                    left: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Styles.yellowColor,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/ieeeprofile.jpeg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 50.0),
                    width: 200,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Styles.blueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        isFollowed ? 'Followed' : 'Follow Community',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Gap(30),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 27.0),
                          child: Icon(
                            Icons.note_alt_outlined,
                            color: Styles.blueColor,
                          ),
                        ),
                        Gap(3),
                        Text(
                          'About us',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Styles.blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(left: 27.0),
                    width: 450,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Styles.yellowColor),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Community Name  :  $communityName',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Styles.blueColor,
                                    ),
                                  ),
                                  Gap(5),
                                  Text(
                                    'Email  :  $communityEmail',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Styles.blueColor,
                                    ),
                                  ),
                                  Gap(5),
                                  Text(
                                    'Phone Number  :  $communityPhone',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Styles.blueColor,
                                    ),
                                  ),
                                  Gap(5),
                                  Text(
                                    'College Name  :  $communityCollege',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Styles.blueColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(30),
                  Container(
                    margin: const EdgeInsets.only(left: 29.0),
                    child: Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Styles.blueColor,
                      ),
                    ),
                  ),
                  Gap(10),
                  Container(
                    margin: const EdgeInsets.only(left: 27.0),
                    width: 450,
                    height: 290,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Styles.yellowColor),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 200,
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/2.jpeg',
                                          height: 125,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Name',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Date: \nLocation:\nPrice:',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Gap(30),
                  Container(
                    margin: const EdgeInsets.only(left: 29.0),
                    child: Text(
                      'All Events',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Styles.blueColor,
                      ),
                    ),
                  ),
                  Gap(10),
                  Container(
                    margin: const EdgeInsets.only(left: 27.0),
                    width: 450,
                    height: 290,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Styles.yellowColor),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 200,
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/2.jpeg',
                                          height: 125,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Name',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Date: \nLocation:\nPrice:',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}