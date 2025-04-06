import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/CV_Create_Screen/Langage_Screen.dart';
import 'screens/MyApp.dart';







void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WJOB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}
