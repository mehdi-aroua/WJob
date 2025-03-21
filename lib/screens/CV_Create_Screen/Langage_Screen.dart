import 'package:flutter/material.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart'; // Si tu veux réutiliser ton chatbot !
import 'package:flutter_wjob/screens/CV_Create_Screen/Add_SocialMedia_Screen.dart'; // Mets le bon chemin si besoin

class AddLanguageScreen extends StatefulWidget {
  const AddLanguageScreen({Key? key}) : super(key: key);

  @override
  State<AddLanguageScreen> createState() => _AddLanguageScreenState();
}

class _AddLanguageScreenState extends State<AddLanguageScreen> with SingleTickerProviderStateMixin {
  final TextEditingController languageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedProficiency = 'Beginner'; // Niveau par défaut
  final List<Map<String, String>> _languages = [];

  bool _showChatBot = false;
  late final AnimationController _animationController;

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
    languageController.dispose();
    descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  void _addLanguage() {
    final language = languageController.text.trim();
    final description = descriptionController.text.trim();

    if (language.isEmpty || selectedProficiency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the language and proficiency.')),
      );
      return;
    }

    setState(() {
      _languages.add({
        'language': language,
        'proficiency': selectedProficiency,
        'description': description,
      });
    });

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      languageController.clear();
      descriptionController.clear();
      selectedProficiency = 'Beginner';
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
            backgroundImage: AssetImage('lib/assets/profiles.png'), // Vérifie le chemin
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
          _buildTextField(languageController, 'Language'),
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

  Widget _buildNextButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_languages.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please add at least one language before continuing.')),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSocialMediaScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
            _buildChatBotButton(), // Si tu veux le chatbot !
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
