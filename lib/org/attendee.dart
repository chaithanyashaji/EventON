import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:universe2024/org/qrscanner.dart';
import 'package:gap/gap.dart';

import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/attendencemodel.dart';

class attendee extends StatefulWidget {
  const attendee({Key? key});

  @override
  State<attendee> createState() => _attendeeState();
}

List<attendModel> attendModelList = [];

class _attendeeState extends State<attendee> {
  @override
  void initState() {
    super.initState();

    final FirebaseFirestore db = FirebaseFirestore.instance;

    String eventId="aaa";

    db.collection("REGISTRATIONS").where("eventId",isEqualTo:eventId ).snapshots().listen((event) {
      if (event.docs.isNotEmpty) {
        for (var element in event.docs) {
          setState(() {
            attendModelList.add(attendModel(
                element.id.toString(),
                element.get("name"),
                element.get("phone"),
                element.get("college"),
                element.get("scanned_status"),
                element.get("email")));
            print(attendModelList.length.toString() + "sdkn fdsn");
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Gap(50),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => qrpage()));
            },
            child: Card(
              color: Styles.blueColor,
              child: Container(
                height: 60,
                width: 350,
                child: Center(
                    child: Text(
                  "SCAN NEW PARTICIPANT",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          Gap(40),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 90,
            margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
            decoration: BoxDecoration(
              // color: Colors.green,
              border: Border.all(color: Styles.yellowColor, width: 1.25),
              borderRadius: BorderRadius.all(
                Radius.circular(7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 3),
                  child: Text(
                    "Total Attended Students  :  " +
                        attendModelList
                            .where((element) => element.status == "YES")
                            .toList()
                            .length
                            .toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Styles.blueColor,
                        fontSize: 16),
                  ),
                ),
                Container(
                  margin:
                      EdgeInsets.only(left: 20, right: 20, top: 3, bottom: 15),
                  child: Text(
                    "Total Registered Students  :  " +
                        attendModelList.length.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Styles.blueColor,
                        fontSize: 16),
                  ),
                )
              ],
            ),
          ),
          Gap(35),
          Expanded(
            child: ListView.builder(
                itemCount: attendModelList.length,
                itemBuilder: (context, index) {
                  var item = attendModelList[index];
                  return Container(
                    height: 165,
                    margin:
                        EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Styles.yellowColor, width: 0.75),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name  :  " + item.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Styles.blueColor),
                                ),
                                Gap(3),
                                Text(
                                  "Phone no  :  " + item.phone,
                                  style: TextStyle(
                                      fontSize: 14, color: Styles.blueColor),
                                ),
                                Gap(3),
                                Text(
                                  "College Name  :  " + item.college,
                                  style: TextStyle(
                                      fontSize: 14, color: Styles.blueColor),
                                ),
                                Gap(3),
                                Text(
                                  "Email Id  :  " + item.email,
                                  style: TextStyle(
                                      fontSize: 14, color: Styles.blueColor),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Styles.yellowColor),
                                // color: Colors.red,
                                // border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),

                                  // FLUTTER BUG FIX
                                ),
                              ),
                              child: Center(
                                  child: Text(
                                item.status == "YES"
                                    ? "Attended"
                                    : "Registered",
                                style: TextStyle(
                                    color: item.status == "YES"
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500),
                              )),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
