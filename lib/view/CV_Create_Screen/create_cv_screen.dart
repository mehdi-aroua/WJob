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
  final TextEditingController _chatController = TextEditingController();

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
    _chatController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });
    
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
    // Request storage permission
    final status = await Permission.photos.request();
    
    if (status.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this app
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permission required'),
            content: const Text('Please enable photos access in settings'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission not granted')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  Future<void> _pickDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2004, 1, 1),
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEducationScreen()),
    );
  }

  void _toggleChat() {
    setState(() {
      _showChatBot = !_showChatBot;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundImage: const AssetImage('lib/assets/profiles.png'),
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
          _buildTextField(_addressController, 'Address'),
          _buildCountryDropdown(),
          _buildTextField(_cityController, 'City'),
          _buildTextField(_zipController, 'Zip Code', keyboardType: TextInputType.number),
          _buildDropdownField('Gender', ['Male', 'Female', 'Other'], _selectedGender, (val) {
            setState(() {
              _selectedGender = val;
            });
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
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : const AssetImage('lib/assets/profiles.png') as ImageProvider,
        child: _profileImage == null
            ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
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
    child: _isLoadingCountries
        ? const Center(child: CircularProgressIndicator())
        : DropdownButtonFormField<String>(
            value: _selectedCountry,
            isExpanded: true, // Fix overflow
            decoration: InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: _countries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(
                  country,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCountry = newValue;
              });
            },
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