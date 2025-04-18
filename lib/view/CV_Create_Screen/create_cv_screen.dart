import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Add_Education_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class CreateCVScreen extends StatefulWidget {
  const CreateCVScreen({super.key});

  @override
  State<CreateCVScreen> createState() => _CreateCVScreenState();
}

class _CreateCVScreenState extends State<CreateCVScreen> with SingleTickerProviderStateMixin {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;
  late AnimationController _animationController;

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  String? _selectedCountry;
  String? _selectedGender;
  List<String> _countries = [];
  bool _isLoadingCountries = false;
  bool _showChatBot = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _fetchCountries();
  }

  @override
  void dispose() {
    _dobController.dispose();
    _aboutMeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    setState(() => _isLoadingCountries = true);
    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> countryNames = data
            .map((country) => country['name']['common'].toString())
            .toList()
            .cast<String>();
        countryNames.sort();
        setState(() {
          _countries = countryNames;
          _isLoadingCountries = false;
        });
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      setState(() {
        _isLoadingCountries = false;
        _countries = ['France', 'Tunisia', 'United States', 'Canada'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading countries: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      await [Permission.camera, Permission.storage].request();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (image != null) {
        setState(() => _profileImage = File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1925),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    final emailPattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    final phonePattern = RegExp(r'^[0-9]{8,}$');

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedCountry == null ||
        _selectedGender == null ||
        _dobController.text.isEmpty ||
        _aboutMeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!emailPattern.hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format')),
      );
      return;
    }

    if (!phonePattern.hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEducationScreen()),
    );
  }

  void _toggleChat() {
    setState(() => _showChatBot = !_showChatBot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Stack(
          children: [
            _buildForm(context),
            if (_showChatBot)
              Positioned(
                right: 10,
                bottom: 80,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Card(
                  elevation: 8,
                  child: const ChatBotWidget(),
                ),
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: _toggleChat,
                child: Icon(
                  _showChatBot ? Icons.close : Icons.chat,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('lib/assets/profiles.png'),
            radius: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 20),
          _buildTextField(_nameController, 'Name'),
          _buildTextField(_emailController, 'Email Address', keyboardType: TextInputType.emailAddress),
          _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
          _buildCountryDropdown(),
          _buildTextField(_cityController, 'City'),
          _buildTextField(_addressController, 'Address'),
          _buildTextField(_zipController, 'Zip Code', keyboardType: TextInputType.number),
          _buildDropdownField('Gender', ['Male', 'Female', 'Other'], _selectedGender, (val) {
            setState(() => _selectedGender = val);
          }),
          _buildDatePickerField(context),
          _buildAboutMeField(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _submitForm,
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          image: _profileImage != null
              ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _profileImage == null
            ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[800])
            : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _selectedCountry,
        hint: const Text('Select Country'),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: _countries.map((country) {
          return DropdownMenuItem(value: country, child: Text(country));
        }).toList(),
        onChanged: (val) => setState(() => _selectedCountry = val),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _pickDateOfBirth(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutMeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _aboutMeController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'About Me',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
