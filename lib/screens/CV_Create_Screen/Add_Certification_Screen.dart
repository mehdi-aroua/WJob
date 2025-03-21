import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:flutter_wjob/screens/CV_Create_Screen/Langage_Screen.dart';
import 'package:flutter_wjob/screens/CV_Create_Screen/Free_Certificates_Screen.dart';

class AddCertificationScreen extends StatefulWidget {
  const AddCertificationScreen({Key? key}) : super(key: key);

  @override
  State<AddCertificationScreen> createState() => _AddCertificationScreenState();
}

class _AddCertificationScreenState extends State<AddCertificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();

  late final AnimationController _animationController;
  bool _showChatBot = false;

  File? _selectedImage;
  String? _imageUrl; // Pour stocker l'URL de l'image sur le web
  final List<Map<String, String>> _certifications = [];

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
    titleController.dispose();
    organizationController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    expirationDateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Sur le web, utilisez l'URL de l'image
        setState(() => _imageUrl = pickedFile.path);
      } else {
        // Sur mobile, utilisez File
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  void _addCertification() {
    final title = titleController.text.trim();
    final organization = organizationController.text.trim();
    final description = descriptionController.text.trim();
    final date = dateController.text.trim();
    final expirationDate = expirationDateController.text.trim();

    if (title.isEmpty ||
        organization.isEmpty ||
        description.isEmpty ||
        date.isEmpty ||
        expirationDate.isEmpty ||
        (_selectedImage == null && _imageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image!')),
      );
      return;
    }

    setState(() {
      _certifications.add({
        'title': title,
        'organization': organization,
        'description': description,
        'date': date,
        'expirationDate': expirationDate,
        'imagePath': kIsWeb ? _imageUrl! : _selectedImage!.path,
      });
    });

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      titleController.clear();
      organizationController.clear();
      descriptionController.clear();
      dateController.clear();
      expirationDateController.clear();
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = '${pickedDate.toLocal()}'.split(' ')[0];
    }
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 20),
          _buildImagePicker(),
          const SizedBox(height: 20),
          _buildTextField(titleController, 'Title'),
          const SizedBox(height: 15),
          _buildTextField(organizationController, 'Organization'),
          const SizedBox(height: 15),
          _buildTextField(descriptionController, 'Description'),
          const SizedBox(height: 15),
          _buildDateField(dateController, 'Date'),
          const SizedBox(height: 15),
          _buildDateField(expirationDateController, 'Expiration Date'),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 30),
          _buildCertificationList(),
          const SizedBox(height: 20),
          _buildFreeCertificateButton(),
          const SizedBox(height: 20),
          _buildNextButton(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Text(
        'Add Certification',
        style: TextStyle(color: Colors.teal, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: _selectedImage != null || _imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(_imageUrl!, fit: BoxFit.cover)
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : const Center(
                  child: Icon(Icons.add_a_photo, color: Colors.teal, size: 40),
                ),
        ),
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

  Widget _buildDateField(TextEditingController controller, String hint) {
    return GestureDetector(
      onTap: () => _pickDate(controller),
      child: AbsorbPointer(
        child: _buildTextField(controller, hint),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _addCertification,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Certification', style: TextStyle(color: Colors.white)),
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

  Widget _buildCertificationList() {
    if (_certifications.isEmpty) {
      return const Center(child: Text('No certifications added yet.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _certifications.length,
      itemBuilder: (context, index) {
        final cert = _certifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: cert['imagePath'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? Image.network(cert['imagePath']!, width: 50, height: 50, fit: BoxFit.cover)
                        : Image.file(File(cert['imagePath']!), width: 50, height: 50, fit: BoxFit.cover),
                  )
                : const Icon(Icons.image, size: 50),
            title: Text(cert['title'] ?? ''),
            subtitle: Text('${cert['organization']} - ${cert['date']}'),
          ),
        );
      },
    );
  }

Widget _buildFreeCertificateButton() {
  return Center(
    child: ElevatedButton.icon(
      onPressed: () {
        // Rediriger vers la page FreeCertificatesScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FreeCertificatesScreen(),
          ),
        );
      },
      icon: const Icon(Icons.card_membership, color: Colors.white),
      label: const Text(
        'Free Certificate',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}

  Widget _buildNextButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_certifications.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add at least one certification before continuing.'),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddLanguageScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
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