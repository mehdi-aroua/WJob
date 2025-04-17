import 'package:flutter/material.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/create_cv_screen.dart';
import 'view/welcome_screen.dart';
import 'view/CV_Create_Screen/Langage_Screen.dart';
import 'view/login_screen/Login_Screen.dart';







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
      home: const LoginScreen(),
    );
  }
}
