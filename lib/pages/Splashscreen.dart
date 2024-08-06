import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universe2024/pages/loginpage.dart';
import 'package:universe2024/pages/new.dart';
import 'package:universe2024/Utiles/app_styles.dart';

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
                  'assets/logosplash.png',
                  width: 400, // Adjust size as needed
                  height: 200,
                ),
                SizedBox(height: 300), // Add spacing between logo and text
              ],
            ),

            ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [Styles.blueColor, Styles.yellowColor], // Gradient colors
                  begin: Alignment.centerLeft, // Gradient start position
                  end: Alignment.centerRight, // Gradient end position
                ).createShader(bounds);
              },
              child: Text(
                'UniVerse', // Replace 'Your Text' with your actual text
                style: TextStyle(
                  fontSize: 25, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Adjust the font weight as needed
                  color: Colors.white, // This color will be overridden by the gradient
                ),
              ),
            )// Add spacing between logo and text

          ],
        ),
      ),
    );
  }
}