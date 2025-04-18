import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/userinfo.dart';
import 'package:flutter_wjob/view/filtre/filterjob.dart';
import 'package:flutter_wjob/view/filtre/user_profile_bottom_sheet.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

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
                        widget.job.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.job.location,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      if (widget.job.timeAgo.isNotEmpty)
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
        ),

        // Chatbot bouton flottant
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.teal,
            onPressed: _toggleChatBot,
            tooltip: 'Chat with Bot',
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
              ),
              child: Icon(_showChatBot ? Icons.close : Icons.chat, color: Colors.white, size: 18),
            ),
          ),
        ),

        // Chatbot widget
        if (_showChatBot)
          Positioned(
            bottom: 60,
            right: 10,
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: const ChatBotWidget(),
            ),
          ),
      ],
    );
  }
}
