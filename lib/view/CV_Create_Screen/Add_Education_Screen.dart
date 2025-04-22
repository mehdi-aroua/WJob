import 'dart:io';

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_wjob/classes/pdfgenerator.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Add_Experience_Screen.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class AddEducationScreen extends StatefulWidget {
  const AddEducationScreen({Key? key}) : super(key: key);

  @override
  _AddEducationScreenState createState() => _AddEducationScreenState();
}

class _AddEducationScreenState extends State<AddEducationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController courseController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController _chatController = TextEditingController();
  final List<String> _messages = [];

  bool _isChatOpen = false;

  List<Map<String, String>> educations = [];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    courseController.dispose();
    degreeController.dispose();
    schoolController.dispose();
    countryController.dispose();
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    _chatController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
  }

  void _sendMessage() {
    String message = _chatController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(message);
        _messages.add("Bot response to: $message");
      });
      _chatController.clear();
    }
  }

  DateTime _parseDate(String date) {
    List<String> parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }
  Future<bool> _requestStoragePermission() async {
    try {
      // Simple approach that works without device info
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      print('Error requesting storage permission: $e');
      // Just return true to continue without permissions
      // This isn't ideal but will prevent crashing
      return true;
    }
  }


  void _submitForm() {
    String course = courseController.text;
    String degree = degreeController.text;
    String school = schoolController.text;
    String country = countryController.text;
    String location = locationController.text;
    String startDate = startDateController.text;
    String endDate = endDateController.text;
    String description = descriptionController.text;

    if (course.isEmpty || degree.isEmpty || school.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      try {
        DateTime start = _parseDate(startDate);
        DateTime end = _parseDate(endDate);
        if (start.isAfter(end)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start date must be before end date.')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format.')),
        );
        return;
      }
    }

    Map<String, String> educationData = {
      'course': course,
      'degree': degree,
      'school': school,
      'country': country,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };

    setState(() {
      educations.add(educationData);
      PdfGenerator.bigList.add(educationData);
      // courseController.clear();
      // degreeController.clear();
      // schoolController.clear();
      // countryController.clear();
      // locationController.clear();
      // startDateController.clear();
      // endDateController.clear();
      // descriptionController.clear();
    });
    print('BIGLIST after education: ${PdfGenerator.bigList}');
    // Add education data to BigList
    Map<String, dynamic> bigListItem = Map<String, dynamic>.from(educationData);
    bigListItem['form_type'] = 'Education';
    PdfGenerator.BigList.add(bigListItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Education added!')),
    );
  }
  Future<void> _saveAndContinue() async {
    if (educations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one education before continuing.'),
        ),
      );
      return;
    }
    print('Final BIGLIST before next screen: ${PdfGenerator.bigList}');

    // Check storage permissions first
    // bool hasPermission = await _requestStoragePermission();
    // if (!hasPermission) {
    //   // Show permission dialog
    //   bool shouldOpenSettings = await showDialog(
    //     context: context,
    //     builder: (ctx) => AlertDialog(
    //       title: Text("Permission Required"),
    //       content: Text("Please grant storage access to save your CV."),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(ctx, false),
    //           child: Text("Cancel"),
    //         ),
    //         TextButton(
    //           onPressed: () => Navigator.pop(ctx, true),
    //           child: Text("Open Settings"),
    //         ),
    //       ],
    //     ),
    //   );

    //   if (shouldOpenSettings) {
    //     await openAppSettings();
    //   }
    //   return;
    // }

    // try {
    //   // Get the CV file from the previous screen's navigation arguments
    //   File? existingPdf;
      
       try {
    //     // First try to get the file from the navigation arguments
    //     existingPdf = ModalRoute.of(context)!.settings.arguments as File?;
    //   } catch (e) {
    //     print('Error getting PDF from arguments: $e');
    //   }
      
    //   // If not available in arguments, look for it in standard locations
    //   if (existingPdf == null || !await existingPdf.exists()) {
    //     print('PDF not found in arguments, looking in standard locations');
        
    //     // First check in Downloads
    //     try {
    //       final downloadFile = File('/storage/emulated/0/Download/cvForm.pdf');
    //       if (await downloadFile.exists()) {
    //         existingPdf = downloadFile;
    //         print('Found PDF in Downloads folder');
    //       }
    //     } catch (e) {
    //       print('Error checking Downloads folder: $e');
    //     }
        
    //     // If not in Downloads, check in app documents directory
    //     if (existingPdf == null) {
    //       try {
    //         final directory = await getApplicationDocumentsDirectory();
    //         final docFile = File('${directory.path}/cvForm.pdf');
    //         if (await docFile.exists()) {
    //           existingPdf = docFile;
    //           print('Found PDF in app documents directory');
    //         }
    //       } catch (e) {
    //         print('Error checking app documents: $e');
    //       }
    //     }
        
    //     // If still not found, use a fallback empty PDF
    //     if (existingPdf == null) {
    //       throw Exception('No existing CV found. Please create a CV first.');
    //     }
    //   }

    //   // Add educations to the PDF
    //   final pdfFile = await PdfGenerator.appendEducationsToCV(
    //     existingPdf: existingPdf,
    //     educations: educations,
    //   );

    //   // Show success message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Education added to CV: ${pdfFile.path}')),
    //   );

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddExperienceScreen(),
          // settings: RouteSettings(arguments: pdfFile),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating CV: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: const AssetImage('lib/assets/profiles.png'),
              radius: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add Education',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField('Course', courseController),
                    _buildTextField('Degree', degreeController),
                    _buildTextField('School', schoolController),
                    _buildCountryPickerField(),
                    _buildTextField('Location', locationController),
                    _buildDateField('Start Date', startDateController),
                    _buildDateField('End Date', endDateController),
                    _buildTextField('Description', descriptionController, maxLines: 3),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: _submitForm,
                          child: const Text(
                            'Add Education',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Your Educations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),

                    educations.isEmpty
                        ? const Text("No education added yet.")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: educations.length,
                            itemBuilder: (context, index) {
                              final education = educations[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text("${index + 1}. ${education['course'] ?? ''}"),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Degree: ${education['degree'] ?? ''}"),
                                      Text("School: ${education['school'] ?? ''}"),
                                      Text("Country: ${education['country'] ?? ''}"),
                                      Text("From: ${education['startDate'] ?? ''} To: ${education['endDate'] ?? ''}"),
                                      Text("Description: ${education['description'] ?? ''}"),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        educations.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed:  _saveAndContinue,
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            if (_isChatOpen)
              const ChatBotWidget(),

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
                    _isChatOpen ? Icons.close : Icons.chat,
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryPickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          showCountryPicker(
            context: context,
            showPhoneCode: false,
            onSelect: (Country country) {
              setState(() {
                countryController.text = country.name;
              });
            },
          );
        },
        child: AbsorbPointer(
          child: TextField(
            controller: countryController,
            decoration: InputDecoration(
              labelText: 'Country',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
      ),
    );
  }
}
