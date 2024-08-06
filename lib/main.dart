import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:universe2024/org/1.dart';
import 'package:universe2024/org/add.dart';
import 'package:universe2024/org/attendee.dart';
import 'package:universe2024/org/home.dart';
import 'package:universe2024/pages/Eventdetails.dart';

import 'package:universe2024/pages/Homepage.dart';
import 'package:universe2024/pages/Signuppage.dart';
import 'package:universe2024/pages/Splashscreen.dart';
import 'package:universe2024/pages/Userpage.dart';
import 'package:universe2024/pages/communitypage.dart';
import 'package:universe2024/pages/loginpage.dart';
import 'package:universe2024/pages/new.dart';
import 'package:universe2024/pages/orgsignup.dart';
import 'package:universe2024/pages/profile.dart';
import 'package:universe2024/pages/search.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniVerse',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme()),
      home: Splashscreen(),
    );
  }
}
