import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/Signuppage.dart';
import 'package:universe2024/pages/firebase.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/pages/orgsignup.dart';


class Loginas extends StatelessWidget {
  const Loginas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles.bgColor,
        body: SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: Stack(
                children: [
                  Align(
                    alignment: const AlignmentDirectional(20, -1.2),
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .width,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.yellowColor,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(-2.7, -1.2),
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .width / 1.3,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 1.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Styles.blueColor,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(2.7, -1.2),
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .width / 1.3,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 1.3,
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
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          child: Column(
                              children: [
                                const Gap(30),
                                Icon(
                                  Icons.person,
                                  size: 150, // Adjust size
                                  color: Colors.white, // Adjust color
                                ),


                                const Gap(10),
                                Text(
                                  "Join as",
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(100),

                                Container(
                                  child: Material(
                                    elevation: 8, // Adjust the elevation as needed
                                    borderRadius: BorderRadius.circular(15), // Set the same border radius as the button
                                    child: SizedBox(
                                      width: 300,
                                      height: 70,// Adjust the width here
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _navigateToNextScreen(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Styles.blueColor,
                                              size: 30, // Adjust the size of the icon as needed
                                            ),
                                            SizedBox(width: 10), // Add some space between the icon and text
                                            Text(
                                              'User',
                                              style: TextStyle(
                                                color: Styles.blueColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                                Gap(30),

                                Container(
                                  child: Material(
                                    elevation: 8, // Adjust the elevation as needed
                                    borderRadius: BorderRadius.circular(15), // Set the same border radius as the button
                                    child: SizedBox(
                                      width: 300,
                                      height: 70,// Adjust the width here
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _navigateToNextScreen2(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: 0, // Remove button elevation
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.groups,
                                              color: Styles.blueColor,
                                              size: 30, // Adjust the size of the icon as needed
                                            ),
                                            SizedBox(width: 10), // Add some space between the icon and text
                                            Text(
                                              'Organization',
                                              style: TextStyle(
                                                color: Styles.blueColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                              ]
                          )
                      )
                  )
                ]
            )
        )
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignupPage()));
  }
}

void _navigateToNextScreen2(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => orgsignup()));
}