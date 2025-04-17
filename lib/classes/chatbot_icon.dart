import 'package:flutter/material.dart';
import 'package:wjob/classes/chat.dart';

class ChatbotIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, 
      right: 20, 
      child: GestureDetector(
        onTap: () {
          Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
        },
          child: ClipOval(
            child: Image.asset(
              'assets/chatbot.png',
              width: 60, 
              height: 60,
              fit: BoxFit.cover,  
            ),
        ),
      ),
    );
  }
}
