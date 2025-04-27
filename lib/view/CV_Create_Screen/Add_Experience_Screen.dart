  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:flutter_wjob/classes/pdfgenerator.dart';
  import 'package:flutter_wjob/view/CV_Create_Screen/Add_Education_Screen.dart';
  import 'package:flutter_wjob/view/CV_Create_Screen/Add_Skill_Screen.dart';
  import 'package:flutter_wjob/widgets/chatbot_widget.dart';
  import 'package:intl/intl.dart';
  import 'package:country_picker/country_picker.dart';
  import 'package:permission_handler/permission_handler.dart';
  import 'package:app_settings/app_settings.dart';
  import 'package:path_provider/path_provider.dart';

  class AddExperienceScreen extends StatefulWidget {
    const AddExperienceScreen({super.key});

    @override
    State<AddExperienceScreen> createState() => _AddExperienceScreenState();
  }

  class _AddExperienceScreenState extends State<AddExperienceScreen> with SingleTickerProviderStateMixin {
    // Controllers pour le formulaire
    final TextEditingController jobTitleController = TextEditingController();
    final TextEditingController companyController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController responsibilitiesController = TextEditingController();

    List<Map<String, String>> experiences = [];
    bool isLoading = false;
    DateTime? startDate;
    DateTime? endDate;
    
    // Variables pour le chat
    late AnimationController _animationController;
    bool _isChatOpen = false;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        lowerBound: 0.0,
        upperBound: 1.0,
      );
    }

    @override
    void dispose() {
      jobTitleController.dispose();
      companyController.dispose();
      countryController.dispose();
      locationController.dispose();
      startDateController.dispose();
      endDateController.dispose();
      responsibilitiesController.dispose();
      _animationController.dispose();
      super.dispose();
    }
    void _goToNextPage() {
        if (experiences.isEmpty) {
          // Show error
          return;
        }

        print('BIGLIST before next screen: ${PdfGenerator.bigList}');
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddSkillScreen(),
          ),
        );
      }

    // Toggle chat
    void _toggleChat() {
      setState(() {
        _isChatOpen = !_isChatOpen;
        if (_isChatOpen) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
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
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Add Experience',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Champs de formulaire
                    _buildTextField('Job Title', jobTitleController),
                    _buildTextField('Company', companyController),
                    _buildCountryPickerField(),
                    _buildTextField('Location', locationController),
                    _buildDateField('Start Date', startDateController, true),
                    _buildDateField('End Date', endDateController, false),

                    const SizedBox(height: 10),
                    const Text(
                      'Responsibilities:',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: responsibilitiesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your responsibilities...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            responsibilitiesController.clear();
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _addExperience,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Experience',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Your Experiences',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    experiences.isEmpty
                        ? const Text('No experience added yet.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: experiences.length,
                            itemBuilder: (context, index) {
                              final exp = experiences[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text('${index + 1}. ${exp['jobTitle']}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Company: ${exp['company']}'),
                                      Text('Country: ${exp['country']}'),
                                      Text('Location: ${exp['location']}'),
                                      Text('From: ${exp['startDate']} To: ${exp['endDate']}'),
                                      Text('Responsibilities: ${exp['responsibilities']}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        experiences.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 20),

                    // In AddExperienceScreen class, update the Next button's onPressed handler

                    ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ),

                    const SizedBox(height: 80),
                  ],
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

    Widget _buildTextField(String label, TextEditingController controller) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
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

    Widget _buildDateField(String label, TextEditingController controller, bool isStartDate) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime initialDate;
            DateTime firstDate = DateTime(1950);
            DateTime lastDate = DateTime.now();
            
            // Pour la date de fin, on vérifie que la date de début est déjà sélectionnée
            if (!isStartDate && startDate != null) {
              initialDate = startDate!.add(const Duration(days: 1));
              firstDate = startDate!.add(const Duration(days: 1));
              lastDate = DateTime(2100);
            } else {
              initialDate = DateTime.now();
            }
            
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            
            if (pickedDate != null) {
              // Mise à jour de la date sélectionnée
              setState(() {
                if (isStartDate) {
                  startDate = pickedDate;
                  // Si la date de fin est avant la nouvelle date de début, on la réinitialise
                  if (endDate != null && endDate!.isBefore(pickedDate)) {
                    endDate = null;
                    endDateController.clear();
                  }
                } else {
                  endDate = pickedDate;
                }
              });
              
              // Format de date plus lisible
              final DateFormat formatter = DateFormat('dd/MM/yyyy');
              controller.text = formatter.format(pickedDate);
            }
          },
        ),
      );
    }

    void _addExperience() {
      String jobTitle = jobTitleController.text.trim();
      String company = companyController.text.trim();
      String country = countryController.text.trim();
      String location = locationController.text.trim();
      String startDateStr = startDateController.text.trim();
      String endDateStr = endDateController.text.trim();
      String responsibilities = responsibilitiesController.text.trim();

      // Validation
      if (jobTitle.isEmpty || company.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job Title and Company are required fields')),
        );
        return;
      }

      // Create experience map
      Map<String, String> experienceData = {
        'jobTitle': jobTitle,
        'company': company,
        'country': country,
        'location': location,
        'startDate': startDateStr,
        'endDate': endDateStr,
        'responsibilities': responsibilities,
      };

      setState(() {
        experiences.add(experienceData);
        PdfGenerator.bigList.add(experienceData);
      });
      
       print('BIGLIST after experience: ${PdfGenerator.bigList}');
      // Add experience data to BigList
      Map<String, dynamic> bigListItem = Map<String, dynamic>.from(experienceData);
      bigListItem['form_type'] = 'Experience';
      PdfGenerator.BigList.add(bigListItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experience added successfully!')),
      );
    }
  }