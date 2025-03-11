import 'package:flutter/material.dart';
import 'package:wjob/view/filterjob.dart';

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
       IconButton(
            icon: Icon(Icons.tune, color: Color(0xFF40E0D0), size: 30),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, 
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: FilterJob(), 
                ),
              );
            },
          ),
        CircleAvatar(
          backgroundImage: AssetImage('assets/propilecv.png'),
        ),
      ],
    );
  }
}
