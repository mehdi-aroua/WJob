import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wjob/classes/pdfgenerator.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Add_CoverLetter.dart';
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
  Uint8List? _imageBytes;

  // Future<void> _pickImageFromGallery() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image, // Only allow image files
  //   );

  //   if (result != null) {
  //     PlatformFile file = result.files.first;

  //     if (kIsWeb) {
  //       // For web, use the bytes property
  //       setState(() {
  //         _imageBytes = file.bytes; // Store the image bytes
  //       });
  //     } else {
  //       // For mobile, use the path property
  //       setState(() {
  //         _profileImage = File(file.path!); // Convert PlatformFile to File
  //       });
  //     }
  //   } else {
  //     print("No image selected."); // Debug statement
  //   }
  // }
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

  // @override
  // void dispose() {
  //   _dobController.dispose();
  //   _aboutMeController.dispose();
  //   _nameController.dispose();
  //   _emailController.dispose();
  //   _phoneController.dispose();
  //   _addressController.dispose();
  //   _cityController.dispose();
  //   _zipController.dispose();
  //   _animationController.dispose();
  //   super.dispose();
  // }

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
    // Request permissions first
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
      return;
    }

    // Try image_picker first
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _imageBytes = null;
      });
      return;
    }

    // Fallback to file_picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        setState(() {
          _profileImage = File(file.path!);
          _imageBytes = null;
        });
      } else if (file.bytes != null) {
        setState(() {
          _imageBytes = file.bytes;
          _profileImage = null;
        });
      }
    }
  } catch (e) {
    print('Image pick error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
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
 Future<bool> _requestStoragePermission() async {
  if (kIsWeb) return true;

  try {
    if (Platform.isAndroid) {
      // For Android, we'll use a simpler approach since DeviceInfoPlugin is failing
      final androidVersion = await Platform.environment['ro.build.version.sdk'];
      final sdkInt = int.tryParse(androidVersion ?? '') ?? 0;
      
      if (sdkInt >= 33) { // Android 13+
        final status = await [Permission.photos, Permission.manageExternalStorage].request();
        return status[Permission.photos]?.isGranted ?? false;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  } catch (e) {
    print('Permission error: $e');
    // Fallback to basic storage permission
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
  void _submitForm() async{
    final emailPattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    final phonePattern = RegExp(r'^[0-9]{8,}$');

    // if (_nameController.text.isEmpty ||
    //     _emailController.text.isEmpty ||
    //     _phoneController.text.isEmpty ||
    //     _addressController.text.isEmpty ||
    //     _selectedCountry == null ||
    //     _selectedGender == null ||
    //     _dobController.text.isEmpty ||
    //     _aboutMeController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please fill all fields')),
    //   );
    //   return;
    // }

    // if (!emailPattern.hasMatch(_emailController.text)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Invalid email format')),
    //   );
    //   return;
    // }

    // if (!phonePattern.hasMatch(_phoneController.text)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Invalid phone number')),
    //   );
    //   return;
    // }

   try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Generating CV...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    
//     bool hasPermission = await _requestStoragePermission();
// print("Permission granted: $hasPermission");

// if (!hasPermission) {
//   // Show explanation and option to open settings
//   bool shouldOpenSettings = await showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: const Text("Permission Required"),
//       content: const Text("We need storage access to save your CV. Please grant permission in app settings."),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, false),
//           child: const Text("Cancel"),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(ctx, true),
//           child: const Text("Open Settings"),
//         ),
//       ],
//     ),
//   );

//   if (shouldOpenSettings) {
//   try {
//     await openAppSettings();
//   } catch (e) {
//     print('Error opening app settings: $e');
//     // Fallback - show manual instructions
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Permission Required"),
//         content: Text("Please enable storage permissions in your device settings."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }
// }
// }

    
    // Add form data to BigList
    PdfGenerator.bigList.add({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'zip': _zipController.text,
      'country': _selectedCountry,
      'gender': _selectedGender,
      'dob': _dobController.text,
      'aboutMe': _aboutMeController.text,
      'form_type': 'Personal Information',
    });
    
    // Generate the PDF
    // final pdfFile = await PdfGenerator.generateCV(
    //   name: _nameController.text,
    //   email: _emailController.text,
    //   phone: _phoneController.text,
    //   address: _addressController.text,
    //   city: _cityController.text,
    //   zip: _zipController.text,
    //   country: _selectedCountry!,
    //   gender: _selectedGender!,
    //   dob: _dobController.text,
    //   aboutMe: _aboutMeController.text,
    //   profileImage: _profileImage,
    // );

    // Close loading dialog
    Navigator.pop(context);

    // Navigate to the next screen immediately
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCoverLetterScreen(), //AddEducationScreen(),
        // settings: RouteSettings(arguments: pdfFile),
      ),
    );
    print('BIGLIST after personal info: ${PdfGenerator.bigList}');
    // // Don't try to open the PDF, just show a message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         const Text("Your CV PDF was saved to:"),
    //         Text(
    //           pdfFile.path,
    //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
    //         ),
    //         const Text("Please use a file manager to open it"),
    //       ],
    //     ),
    //     duration: const Duration(seconds: 6),
    //   ),
    // );
  } catch (e) {
    // Close loading dialog if it's open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    print('Error generating PDF: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating PDF: $e')),
    );
  }
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
          // GestureDetector(
          //       onTap: _pickImageFromGallery,
          //       child: CircleAvatar(
          //         radius: 50,
          //         backgroundImage: _imageBytes != null
          //             ? MemoryImage(_imageBytes!)
          //             : _profileImage != null
          //                 ? FileImage(_profileImage!)
          //                 : const AssetImage('lib/assets/profiles.png')
          //                     as ImageProvider, // Default image
          //         child: _imageBytes == null && _profileImage == null
          //             ? Icon(Icons.camera_alt, size: 20)
          //             : null,
          //       ),
          //     ),
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
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.teal, width: 2),
              image: _getProfileImageProvider(),
            ),
            child: (_profileImage == null && _imageBytes == null)
              ? Icon(Icons.person, size: 60, color: Colors.grey[800])
              : null,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  DecorationImage? _getProfileImageProvider() {
    if (_profileImage != null) {
      try {
        return DecorationImage(
          image: FileImage(_profileImage!),
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Error loading image from file: $e');
        return null;
      }
    } else if (_imageBytes != null) {
      try {
        return DecorationImage(
          image: MemoryImage(_imageBytes!),
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('Error loading image from memory: $e');
        return null;
      }
    }
    return null;
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
