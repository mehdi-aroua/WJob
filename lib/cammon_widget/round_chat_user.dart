import 'package:flutter/material.dart';

class RoundChatUser extends StatefulWidget {
  const RoundChatUser({
    super.key,
    required this.changingText,
    required this.img,
  });

  final String changingText;
  final ImageProvider img;

  @override
  State<RoundChatUser> createState() => _RoundChatUserState();
}

class _RoundChatUserState extends State<RoundChatUser> {
  @override
  Widget build(BuildContext context) {
     var screenSize = MediaQuery.of(context).size;
     String languageCode = Localizations.localeOf(context).languageCode;
    return Container(
      padding: languageCode == 'ar' 
      ? EdgeInsets.only(left: 90)
      : EdgeInsets.only(right: 90),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(50), // Adjust the radius as needed
            child: Image(
              image: widget.img,
              width: screenSize.width*0.13,
              height: screenSize.height*0.068,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            width: screenSize.width*0.025,
          ),
          Text(widget.changingText, style: TextStyle(fontSize: 20,color: Colors.white)),
        ],
      ),
    );
  }
}
