import 'package:flutter/material.dart';

class RoundChatRestaurant extends StatefulWidget {
  const RoundChatRestaurant({
    super.key,
    required this.changingText,
    required this.img,
  });

  final String changingText;
  final ImageProvider img;

  @override
  State<RoundChatRestaurant> createState() => _RoundChatRestaurantState();
}

class _RoundChatRestaurantState extends State<RoundChatRestaurant> {
  @override
  Widget build(BuildContext context) {
     var screenSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(right: 90),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(50), 
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
