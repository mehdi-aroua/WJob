import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/chatbot_icon.dart';
import 'package:flutter_wjob/classes/calendarscreen.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:flutter_wjob/classes/class_job_card.dart';
import 'package:flutter_wjob/classes/class_header.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';

class Jobmatching extends StatefulWidget {
  final List<JobItem>? jobs;
  const Jobmatching({Key? key, this.jobs}) : super(key: key);

  @override
  State<Jobmatching> createState() => _JobmatchingState();
}

class _JobmatchingState extends State<Jobmatching> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _showChatBot = false;
  late List<JobItem> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = widget.jobs ?? []; 
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final jobList = _jobs;
    
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
                    child: ListView.builder(
                      itemCount: jobList.length,
                      itemBuilder: (context, index) {
                        return JobCard(job: jobList[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                ],
              ),
            ),

            // Chatbot bouton + widget
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: _toggleChatBot,
                tooltip: 'Chat with Bot',
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
                  ),
                  child: Icon(_showChatBot ? Icons.close : Icons.chat, color: Colors.white),
                ),
              ),
            ),
            if (_showChatBot)
              Positioned(
                bottom: 80,
                right: 20,
                child: Container(
                  width: 300,
                  height: 400,
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
        ),
      ),
    );
  }
}
