import 'package:flutter/material.dart';

class Societies extends StatefulWidget {
  const Societies({Key? key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<Societies> {
  late double height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'IEEE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Scrolling container for event posters
              Container(
                height: height * 0.41,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Workshop',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Replace Image.asset with your actual poster images
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/bg.jpg',
                              width: width * 0.4, // Adjusted width
                              height: 150,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/bg.jpg',
                              width: width * 0.4, // Adjusted width
                              height: 150,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/bg.jpg',
                              width: width * 0.4, // Adjusted width
                              height: 150,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/bg.jpg',
                              width: width * 0.4, // Adjusted width
                              height: 150,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/bg.jpg',
                              width: width * 0.4, // Adjusted width
                              height: 150,
                            ),
                          ),
                          // Add more Image.asset widgets as needed
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Container for upcoming events list
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Container(
                  height: height * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      // List of upcoming events
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/bg.jpg',
                                width: width * 0.8,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/bg.jpg',
                                width: width * 0.8,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/bg.jpg',
                                width: width * 0.8,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Add more Image.asset widgets as needed
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
