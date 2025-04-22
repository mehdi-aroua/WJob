import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/pdfgenerator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Add_SocialMedia_Screen.dart';

class AddLanguageScreen extends StatefulWidget {
  const AddLanguageScreen({Key? key}) : super(key: key);

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> with SingleTickerProviderStateMixin {
  final TextEditingController descriptionController = TextEditingController();

  String selectedLanguage = 'English'; // Default language
  String selectedProficiency = 'Beginner'; // Niveau par défaut
  final List<Map<String, String>> _languages = [];

  bool _showChatBot = false;
  late final AnimationController _animationController;

  List<String> supportedLanguages = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSupportedLanguages();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  Future<void> _loadSupportedLanguages() async {
    const url = 'https://restcountries.com/v3.1/all';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> countries = json.decode(response.body);
        final Set<String> languages = {};

        for (var country in countries) {
          final langs = country['languages'];
          if (langs != null && langs is Map) {
            languages.addAll(langs.values.map((e) => e.toString()));
          }
        }

        setState(() {
          supportedLanguages = languages.toList()..sort();
          selectedLanguage = supportedLanguages.first;
        });
      } else {
        throw Exception('Failed to load languages');
      }
    } catch (e) {
      debugPrint('Error loading languages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load languages from API')),
      );
    }
  }

  void _addLanguage() {
    final language = selectedLanguage;
    final description = descriptionController.text.trim();

    if (language.isEmpty || selectedProficiency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language and proficiency.')),
      );
      return;
    }

    Map<String, String> languageData = {
      'language': language,
      'proficiency': selectedProficiency,
      'description': description,
      'form_type': 'Language',
    };

    setState(() {
      _languages.add(languageData);
      PdfGenerator.bigList.add(languageData);
    });
    print('BIGLIST after language: ${PdfGenerator.bigList}');
    // Add language data to BigList
    Map<String, dynamic> bigListItem = Map<String, dynamic>.from(languageData);
    bigListItem['form_type'] = 'Language';
    PdfGenerator.BigList.add(bigListItem);

    _resetForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language added successfully!')),
    );
  }

  void _resetForm() {
    setState(() {
      descriptionController.clear();
      selectedProficiency = 'Beginner';
      selectedLanguage = supportedLanguages.isNotEmpty ? supportedLanguages.first : 'English';
    });
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.teal),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Back',
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: AssetImage('lib/assets/profiles.png'),
            radius: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 20),
          _buildLanguageDropdown(),
          const SizedBox(height: 15),
          _buildProficiencyDropdown(),
          const SizedBox(height: 15),
          _buildTextField(descriptionController, 'Description (optional)'),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 30),
          _buildLanguageList(),
          const SizedBox(height: 30),
          _buildNextButton(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Text(
        'Add Language',
        style: TextStyle(color: Colors.teal, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return supportedLanguages.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : DropdownButtonFormField<String>(
            value: selectedLanguage,
            items: supportedLanguages
                .map((language) => DropdownMenuItem(value: language, child: Text(language)))
                .toList(),
            onChanged: (value) {
              setState(() => selectedLanguage = value!);
            },
            decoration: InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
  }

  Widget _buildProficiencyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedProficiency,
      items: ['Beginner', 'Intermediate', 'Advanced', 'Fluent', 'Native']
          .map((level) => DropdownMenuItem(value: level, child: Text(level)))
          .toList(),
      onChanged: (value) {
        setState(() => selectedProficiency = value!);
      },
      decoration: InputDecoration(
        labelText: 'Proficiency',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _addLanguage,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Language', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetForm,
          icon: const Icon(Icons.cancel, color: Colors.teal),
          label: const Text('Cancel', style: TextStyle(color: Colors.teal)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            side: const BorderSide(color: Colors.teal),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageList() {
    if (_languages.isEmpty) {
      return const Center(child: Text('No languages added yet.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final lang = _languages[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: Text(lang['language'] ?? ''),
            subtitle: Text('${lang['proficiency']} - ${lang['description'] ?? ''}'),
          ),
        );
      },
    );
  }
  bool isLoading = false;
  void _goToNextPage() {
    if (_languages.isEmpty) {
      // Show error
      return;
    }

    print('BIGLIST before next screen: ${PdfGenerator.bigList}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSocialMediaScreen(),
      ),
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: ElevatedButton(
        onPressed:_goToNextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  // Create a temporary file from bytes
  Future<File> _createTempFileFromBytes(List<int> bytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
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
            _buildChatBotButton(),
            if (_showChatBot) _buildChatBot(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBotButton() {
    return Positioned(
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
    );
  }

  Widget _buildChatBot() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: const ChatBotWidget(),
      ),
    );
  }
}
