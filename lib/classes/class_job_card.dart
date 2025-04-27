import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/userinfo.dart';
import 'package:flutter_wjob/view/filtre/filterjob.dart';
import 'package:flutter_wjob/view/filtre/user_profile_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'class_job_item.dart';

class JobCard extends StatefulWidget {
  final JobItem job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _showChatBot = false;
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
     _userDataFuture = _getUserDataWithErrorHandling();
  }



  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }
 Future<Map<String, dynamic>> _getUserDataWithErrorHandling() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'token': prefs.getString('token') ?? '',
        'userId': prefs.getString('userId') ?? '',
        'nom': prefs.getString('nom') ?? '',
        'prenom': prefs.getString('prenom') ?? '',
        'email': prefs.getString('email') ?? '',
        'phone': prefs.getString('phone') ?? '',
        'ville': prefs.getString('ville') ?? '',
        'dateAnniversaire': prefs.getString('dateAnniversaire') ?? '',
        'photo': prefs.getString('photo') ?? 'lib/assets/profiles.png',
      };
    } catch (e) {
      return {
        'token': '',
        'userId': '',
        'nom': '',
        'prenom': '',
        'email': '',
        'phone': '',
        'ville': '',
        'dateAnniversaire': '',
        'photo': 'lib/assets/profiles.png',
      };
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
   return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading user data'));
        }

        final userData = snapshot.data ?? {};
        
        final UserInfo user = UserInfo(
          picture: userData['photo']?.isNotEmpty == true 
              ? userData['photo'] 
              : "/lib/assets/profiles.png",
          name: "${userData['prenom']} ${userData['nom']}".trim(),
          resume: "Computer Science and Engineering Student | Passionate about Software Development and Project Management | Ambitious Entrepreneur",
          email: userData['email'] ?? "No email",
          phoneCountryCode: "Tunisia (+216)", 
          phoneNumber: userData['phone'] ?? "No phone",
        );


    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.job.icon, color: const Color(0xFF40E0D0), size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title ?? 'No title',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.job.location ?? 'Location not specified',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      if (widget.job.timeAgo != null && widget.job.timeAgo!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 25, color: Color(0xFF40E0D0)),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.job.timeAgo} | viewed",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.close, color: Colors.grey, size: 25),
                    const SizedBox(height: 55),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF40E0D0), size: 25),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: UserProfileBottomSheet(user: user,jobList: [widget.job],),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  );
  }
}
