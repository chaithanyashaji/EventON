import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universe2024/pages/qrcode.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/Utiles/app_styles.dart';

class EventDetails extends StatefulWidget {
  final String eventKey;
  const EventDetails({Key? key, required this.eventKey}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late Stream<QuerySnapshot> _stream;

  var _trimMode = TrimMode.Line;
  int _trimLines = 4;
  int _trimLength = 150;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('event')
        .where(FieldPath.documentId, isEqualTo: widget.eventKey)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          QueryDocumentSnapshot firstDocument = documents.first;

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height /2,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Container(
                                  child:Image.asset('assets/13.jpg'),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image:DecorationImage(
                                image: AssetImage('assets/13.jpg'), // Path to your asset image
                                fit: BoxFit.cover, // Adjust the fit as needed
                              ),

                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 325,
                        left: MediaQuery.of(context).size.width / 8,
                        right: MediaQuery.of(context).size.width / 8,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.25),
                                spreadRadius: 3,
                                blurRadius: 15,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Styles.yellowColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 18.0, right: 18, top: 18),
                                child: Text(
                                  firstDocument['eventName'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Styles.blueColor),
                                ),
                              ),
                              Gap(0),
                              Padding(
                                padding: EdgeInsets.only(left: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "- ${firstDocument['eventtype']}  :  ${firstDocument['eventtime']}",
                                      style: TextStyle(
                                          color: Styles.blueColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    Gap(0),
                                    Text(
                                      "- ${firstDocument['eventDate']}  :  ${firstDocument['eventtime']}",
                                      style: TextStyle(
                                          color: Styles.blueColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    Gap(0),
                                    Text(
                                      "- For queries:  ${firstDocument['eventcontact']}",
                                      style: TextStyle(
                                          color: Styles.blueColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height /2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 35, right: 35),
                        child: Text(
                          "Description",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Styles.blueColor,
                              fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 35.0, right: 35, top: 15, bottom: 15),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 125,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: ReadMoreText(
                              firstDocument['eventdetails'],
                              trimMode: _trimMode,
                              trimLines: _trimLines,
                              trimLength: _trimLength,
                              style: TextStyle(color: Styles.blueColor),
                              colorClickableText: Colors.blue,
                              trimCollapsedText: 'Read More',
                              trimExpandedText: 'Read less',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 35, top: 15, right: 35),
                        child: Text(
                          "Venue",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Styles.blueColor,
                              fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 35.0, right: 35, top: 15, bottom: 30),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Styles.yellowColor, width: 0.75),
                              bottom: BorderSide(
                                  color: Styles.yellowColor, width: 0.75),
                            ),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.only(top: 8.0, bottom: 15),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(firstDocument['eventLocation'],
                                  style: TextStyle(color: Styles.blueColor)),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: 35, top: 15, right: 35),
                                child: Text(
                                  "Ticket Price",
                                  style: TextStyle(
                                      color: Styles.yellowColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 35, top: 5, right: 5, bottom: 20),
                                height: 34,
                                child: Text(
                                  firstDocument['eventPrice'],
                                  style: TextStyle(
                                      color: Styles.blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                          Gap(80),
                          Container(
                            margin: EdgeInsets.only(
                                left: 20, top: 5, right: 10, bottom: 20),
                            height: 34,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Styles.blueColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            QrGenerationScreen(id: '')));
                              },
                              child: Text(
                                "Register Now",
                                style: TextStyle(
                                    color: Styles.yellowColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}