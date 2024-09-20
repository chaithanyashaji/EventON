import 'dart:async';
import 'package:flutter/material.dart';
import 'package:EventON/pages/loginpage.dart';
import 'package:gap/gap.dart';

class Splashscreen extends StatefulWidget {
  @override
  State<Splashscreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => loginpage(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/EventOn.png',
                  width: 150, // Adjust size as needed

                ),
                Gap(10),
                Text(
                  'Lead with EventOn',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,color: Colors.black,),
                )// Add spacing between logo and text
              ],
            ),
// Add spacing between logo and text

          ],
        ),
      ),
    );
  }
}