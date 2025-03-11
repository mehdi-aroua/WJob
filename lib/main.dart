import 'package:flutter/material.dart';
import 'package:wjob/view/jobmatching.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Jobmatching(),
    );
  }
}
