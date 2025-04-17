import 'package:flutter/material.dart';
import 'package:wjob/classes/chatbot_icon.dart';
import 'package:wjob/classes/calendarscreen.dart';
import '../classes/class_job_item.dart';
import '../classes/class_job_card.dart';
import '../classes/class_header.dart';
// 

class Jobmatching extends StatelessWidget {
   final List<JobItem>? jobs;
   Jobmatching({ this.jobs});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final jobList = jobs ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                children: [
                  Header(),
                  SizedBox(height: screenHeight * 0.05),
                  Expanded(
                    child: SizedBox(
                      height: screenHeight * 0.75,
                      child: ListView.builder(
                        itemCount: jobList.length,
                        itemBuilder: (context, index) {
                          return JobCard(job: jobList[index]);
                        },
                      ),
                    ),
                  ),
                  // Red button to navigate to CalendarScreen
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, 
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Go to Calendar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ChatbotIcon(),
          ],
        ),
      ),
    );
  }
}
