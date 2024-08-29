import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';
import 'package:universe2024/org/attendencemodel.dart';
import 'package:universe2024/org/qrscanner.dart';

class Attendee extends StatefulWidget {
  final String eventId;

  const Attendee({Key? key, required this.eventId}) : super(key: key);

  @override
  State<Attendee> createState() => _AttendeeState();
}

class _AttendeeState extends State<Attendee> {
  List<attendModel> attendModelList = [];
  List<attendModel> filteredList = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchAttendees();
  }

  Future<void> fetchAttendees() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    attendModelList.clear();

    db.collection("REGISTRATIONS")
        .where('eventId', isEqualTo: widget.eventId)
        .snapshots()
        .listen((event) async {
      if (event.docs.isNotEmpty) {
        List<attendModel> newAttendees = [];
        for (var element in event.docs) {
          newAttendees.add(attendModel(
            element.id.toString(),
            element.get("userName"),
            element.get("ScannedStatus"),
            element.get("PaymentStatus"),
            element.get("_MembershipId"),
            element.get("_branch"),
            element.get("_collegeName"),
            element.get("_email"),
            element.get("_mobileNumber"),
            element.get("_rollNo"),
            element.get("_semester"),
          ));
        }
        setState(() {
          attendModelList = newAttendees;
          filteredList = newAttendees;
        });
      }
    });
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredList = attendModelList;
      });
    } else {
      setState(() {
        filteredList = attendModelList
            .where((element) =>
            element.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Registrants',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        actions: [
          Image.asset('assets/EventOn.png', height: 32),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  _filterSearchResults(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search Users...",
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Gap(10),
          InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => QRPage()));
            },
            child: Card(
              color: Styles.blueColor,
              child: Container(
                height: 60,
                width: 350,
                child: Center(
                  child: Text("SCAN NEW PARTICIPANT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          Gap(20),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 90,
            margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Styles.yellowColor, width: 1.25),
              borderRadius: BorderRadius.all(
                Radius.circular(7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: 20, right: 20, top: 15, bottom: 3),
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
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: 20, right: 20, top: 3, bottom: 15),
                  child: Text(
                    "Total Registered Students  :  " +
                        attendModelList.length.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Styles.blueColor,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
          Gap(35),
          Expanded(
            child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  var item = filteredList[index];
                  return Container(
                    height: 260,
                    margin: EdgeInsets.only(
                        left: 20, right: 20, top: 5, bottom: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Styles.yellowColor, width: 0.75),
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
                                  "${index + 1}. Name  :  " + item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "College Name  :  " + item.collegeName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "Branch  :  " + item.branch,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "Semester  :  " + item.semester,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "Roll No  :  " + item.rollNo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "Email  :  " + item.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "Mobile Number  :  " + item.mobileNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
                                Text(
                                  "Membership ID  :  " + item.MembershipId,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Styles.blueColor,
                                  ),
                                ),
                                Gap(3),
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
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Center(
                                  child: Text(
                                    item.status == "YES" ? "Attended" : "Registered",
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
