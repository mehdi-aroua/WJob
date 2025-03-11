import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wjob/cammon/color_extension.dart';
import 'package:wjob/classes/round_text_filed.dart';
import 'package:wjob/view/jobmatching.dart';

class ApplyQuestion extends StatefulWidget {
  @override
  _ApplyQuestionState createState() => _ApplyQuestionState();
}

class _ApplyQuestionState extends State<ApplyQuestion> {
  final TextEditingController mobileDevController = TextEditingController();
  final TextEditingController flutterController = TextEditingController();
  final TextEditingController cSharpController = TextEditingController();
  String? commutingAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'label': 'How many years of work experience do you have with mobile Application Development*',
      'controller': TextEditingController(),
    },
    {
      'label': 'How many years of work experience do you have with Flutter*',
      'controller': TextEditingController(),
    },
    {
      'label': 'How many years of work experience do you have with C#*',
      'controller': TextEditingController(),
    },
  ];
void _showCoachingDialog() {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Do you want AI coaching for interviews?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Jobmatching()));
                  },
                  child: Text(
                    'Not Now',
                    style: TextStyle(
                      fontSize: 18,
                      color: TColor.placeholder,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCoachingLinks();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _launchURL(url) async {
  final uri = Uri.parse(url);
  
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  } catch (e) {
    // Handle any exceptions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error launching URL: $e')),
    );
  }
}

void _showCoachingLinks() {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Interview Coaching',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Boost your interview skills with AI-powered coaching:',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _launchURL('https://huru.ai'),
              icon: Icon(Icons.school, color: Colors.white),
              label: Text(
                'Huru.ai - Free AI Practice',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFF007BFF),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _launchURL('https://coachhub.com'),
              icon: Icon(Icons.person, color: Colors.white),
              label: Text(
                'CoachHub - Pro Coaching',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Apply to ...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Text(
                'Additional Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ...questions.map((q) => _buildInputField(q['label'], q['controller'])).toList(),
              SizedBox(height: 16),
              Text('Are you comfortable commuting to this job’s location?*'),
              Row(
                children: [
                  Radio(
                    value: 'Yes',
                    groupValue: commutingAnswer,
                    onChanged: (value) {
                      setState(() {
                        commutingAnswer = value.toString();
                      });
                    },
                    activeColor: TColor.primary,
                  ),
                  Text('Yes'),
                  SizedBox(width: 16),
                  Radio(
                    value: 'No',
                    groupValue: commutingAnswer,
                    onChanged: (value) {
                      setState(() {
                        commutingAnswer = value.toString();
                      });
                    },
                    activeColor: TColor.primary,
                  ),
                  Text('No'),
                ],
              ),
              SizedBox(height: 40,),
              Center(
                child: ElevatedButton(
                  onPressed: _showCoachingDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        RoundTextFiled(
                  controller: controller,
                  hintText: '0',
                  keyboardType: TextInputType.number,
                ),
        
        SizedBox(height: 16),
      ],
    );
  }
}