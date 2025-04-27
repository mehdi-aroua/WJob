import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/calendarscreen.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_wjob/cammon/color_extension.dart';
import 'package:flutter_wjob/classes/round_text_filed.dart';
import 'package:flutter_wjob/view/filtre/jobmatching.dart';

class ApplyQuestion extends StatefulWidget {
List<JobItem> jobList = [];

ApplyQuestion({Key? key, required this.jobList}) : super(key: key);
  @override
  _ApplyQuestionState createState() => _ApplyQuestionState();
}

class _ApplyQuestionState extends State<ApplyQuestion> {
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController toolsController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController interestController = TextEditingController();

  String? commutingAnswer;

  final List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    questions.addAll([
      {
        'label': 'How many years of relevant work experience do you have?',
        'controller': experienceController,
      },
      {
        'label': 'Which tools, technologies, or frameworks are you most comfortable with?',
        'controller': toolsController,
      },
      {
        'label': 'Can you describe a recent project or task you worked on in your field?',
        'controller': projectController,
      },
      {
        'label': 'What are your strongest professional skills?',
        'controller': skillsController,
      },
      {
        'label': 'Why are you interested in this position?',
        'controller': interestController,
      },
    ]);
  }
// ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) =>  CalendarScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text(
//                       'Go to Calendar',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
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
                        MaterialPageRoute(builder: (context) => CalendarScreen(jobList: widget.jobList)),//Jobmatching(jobs: widget.jobs,)
                      );
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
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

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 5),
        RoundTextFiled(
          controller: controller,
          hintText: '',
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _validateAndSubmit() {
    // Vérification de l'expérience pour s'assurer que c'est un nombre valide
    if (experienceController.text.isNotEmpty && double.tryParse(experienceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid number for years of experience'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ajouter d'autres validations pour les autres champs si nécessaire

    // Si tout est valide, afficher le dialogue
    _showCoachingDialog();
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
              SizedBox(height: 10),
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
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _validateAndSubmit, // Appel de la méthode de validation et soumission
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
}
