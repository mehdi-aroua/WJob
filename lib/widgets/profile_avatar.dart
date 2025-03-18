import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundImage: AssetImage('assets/profiles.jpg'), // Change path
      backgroundColor: Colors.grey.shade300,
    );
  }
}
