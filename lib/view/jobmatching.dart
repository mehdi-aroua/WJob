import 'package:flutter/material.dart';
import 'package:wjob/classes/chatbot_icon.dart';
import '../classes/class_job_item.dart';
import '../classes/class_job_card.dart';
import '../classes/class_header.dart';

class Jobmatching extends StatelessWidget {
  final List<JobItem> jobs = [
    JobItem(title: "Mobile Application developer", location: "EMEA (Remote)", timeAgo: "3 hours ago", icon: Icons.business),
    JobItem(title: "Mobile Application developer", location: "EMEA (Remote)", timeAgo: "3 hours ago", icon: Icons.eco),
    JobItem(title: "Mobile Application developer", location: "Canada (Remote)", timeAgo: "6 hours ago", icon: Icons.brush),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                  SizedBox(
                    height: screenHeight * 0.75,
                    child: ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(job: jobs[index]);
                      },
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
