import 'package:flutter/material.dart';
import 'package:wjob/classes/userinfo.dart';
import 'package:wjob/view/filterjob.dart';
import 'package:wjob/view/user_profile_bottom_sheet.dart';
import 'class_job_item.dart';

class JobCard extends StatelessWidget {
  final JobItem job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserInfo user = UserInfo(
    picture: "assets/propilecv.png", 
    name: "Mehdi Aroua",
    resume: "Computer Science and Engineering Student | Passionate about Software Development and Project Management | Ambitious Entrepreneur",
    email: "mehdiaroua044@gmail.com",
    phoneCountryCode: "Tunisia (+216)",
    phoneNumber: "99085551",
  );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(job.icon, color: Color(0xFF40E0D0), size: 30),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12,),
                  Text(
                    job.location,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 12,),
                  if (job.timeAgo.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 25, color: Color(0xFF40E0D0)),
                        SizedBox(width: 5),
                        Text(
                          "${job.timeAgo} | viewed",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(Icons.close, color: Colors.grey, size: 25),
                SizedBox(height: 55),
                
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Color(0xFF40E0D0), size: 25),
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
                        child: UserProfileBottomSheet(user: user), 
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}