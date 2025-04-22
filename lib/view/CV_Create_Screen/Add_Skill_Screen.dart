import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/pdfgenerator.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Add_Certification_Screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({Key? key}) : super(key: key);

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController skillController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<Map<String, String>> skills = [];
  String? selectedLevel;

  final List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];

  late AnimationController _animationController;
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
    skillController.dispose();
    descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _showChatBot = !_showChatBot;
      _showChatBot ? _animationController.forward() : _animationController.reverse();
    });
  }
  bool isLoading = false;
  // Future<void> _goToNextPage() async {
  //   if (skills.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please add at least one skill!')),
  //     );
  //     return;
  //   }

  //   // Request storage permission
  //   try {
  //     // Simple approach that works without device info
  //     if (Platform.isAndroid || Platform.isIOS) {
  //       final status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         // Show permission dialog
  //         bool shouldOpenSettings = await showDialog(
  //           context: context,
  //           builder: (ctx) => AlertDialog(
  //             title: Text("Permission Required"),
  //             content: Text("Please grant storage access to save your CV."),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(ctx, false),
  //                 child: Text("Cancel"),
  //               ),
  //               TextButton(
  //                 onPressed: () => Navigator.pop(ctx, true),
  //                 child: Text("Open Settings"),
  //               ),
  //             ],
  //           ),
  //         );

  //         if (shouldOpenSettings) {
  //           await openAppSettings();
  //         }
  //         return;
  //       }
  //     }
  //   } catch (e) {
  //     print('Error requesting storage permission: $e');
  //     // Continue anyway
  //   }

  //   setState(() => isLoading = true);

  //   try {
  //     // Get the CV file from the previous screen's navigation arguments
  //     File? existingPdf;
      
  //     try {
  //       // First try to get the file from the navigation arguments
  //       existingPdf = ModalRoute.of(context)!.settings.arguments as File?;
  //     } catch (e) {
  //       print('Error getting PDF from arguments: $e');
  //     }
      
  //     // If not available in arguments, look for it in standard locations
  //     if (existingPdf == null || !await existingPdf.exists()) {
  //       print('PDF not found in arguments, looking in standard locations');
        
  //       // First check in Downloads
  //       try {
  //         final downloadFile = File('/storage/emulated/0/Download/cvForms.pdf');
  //         if (await downloadFile.exists()) {
  //           existingPdf = downloadFile;
  //           print('Found PDF in Downloads folder');
  //         }
  //       } catch (e) {
  //         print('Error checking Downloads folder: $e');
  //       }
        
  //       // If not in Downloads, check in app documents directory
  //       if (existingPdf == null) {
  //         try {
  //           final directory = await getApplicationDocumentsDirectory();
  //           final docFile = File('${directory.path}/cvForms.pdf');
  //           if (await docFile.exists()) {
  //             existingPdf = docFile;
  //             print('Found PDF in app documents directory');
  //           }
  //         } catch (e) {
  //           print('Error checking app documents: $e');
  //         }
  //       }
        
  //       // If still not found, use a fallback empty PDF
  //       if (existingPdf == null) {
  //         throw Exception('No existing CV found. Please create a CV first.');
  //       }
  //     }

  //     // Append skills to the CV
  //     final File updatedPdf = await PdfGenerator.appendSkillsToCV(
  //       existingPdf: existingPdf,
  //       skills: skills,
  //     );

  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Skills added to CV: ${updatedPdf.path}')),
  //     );

  //     setState(() => isLoading = false);

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const AddCertificationScreen(),
  //         settings: RouteSettings(arguments: updatedPdf),
  //       ),
  //     );
  //   } catch (e) {
  //     setState(() => isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error updating CV: ${e.toString()}')),
  //     );
  //   }
  // }

  void _addSkill() {
    final skill = skillController.text.trim();
    final description = descriptionController.text.trim();

    if (skill.isEmpty || selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a skill and select a level!')),
      );
      return;
    }

    Map<String, String> skillData = {
      'skill': skill,
      'level': selectedLevel!,
      'description': description,
      'form_type': 'Skill',
    };

    setState(() {
      skills.add(skillData);
      PdfGenerator.bigList.add(skillData);
    });
    print('BIGLIST after skill: ${PdfGenerator.bigList}');
    // Add skill data to BigList
    Map<String, dynamic> bigListItem = Map<String, dynamic>.from(skillData);
    bigListItem['form_type'] = 'Skill';
    PdfGenerator.BigList.add(bigListItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skill added successfully!')),
    );
  }

  void _resetForm() {
    setState(() {
      skillController.clear();
      descriptionController.clear();
      selectedLevel = null;
    });
  }

    void _goToNextPage() {
        if (skills.isEmpty) {
          print("error in skills ");
          return;
        }

        print('BIGLIST before next screen: ${PdfGenerator.bigList}');
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddCertificationScreen(),
          ),
        );
      }


  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.teal),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: AssetImage('lib/assets/profiles.png'),
            radius: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillLevelDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedLevel,
      decoration: InputDecoration(
        labelText: 'Skill Level',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: skillLevels.map((level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text(level),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedLevel = value;
        });
      },
      validator: (value) => value == null ? 'Please select a level' : null,
    );
  }

  Widget _buildSkillList() {
    if (skills.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No skills added yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(skill['skill']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level: ${skill['level']}'),
                if (skill['description']?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Description: ${skill['description']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => skills.removeAt(index)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _addSkill,
          icon: const Icon(Icons.add),
          label: const Text('Add Skill'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetForm,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton.icon(
        onPressed: _goToNextPage,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Resume Skills',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'ADD SKILL',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: skillController,
            decoration: InputDecoration(
              labelText: 'Skill Name',
              hintText: 'e.g. Flutter, Photoshop, Project Management',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          _buildSkillLevelDropdown(),
          const SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Brief description of your skill level and experience',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          _buildTopButtons(),
          const SizedBox(height: 30),
          _buildSkillList(),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildForm(),
            if (_showChatBot)
              Positioned(
                bottom: 80,
                right: 20,
                child: ChatBotWidget(),
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: _toggleChat,
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    _showChatBot ? Icons.close : Icons.chat,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
