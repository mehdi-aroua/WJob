import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Langage_Screen.dart';
import 'package:flutter_wjob/view/CV_Create_Screen/Free_Certificates_Screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_wjob/classes/pdfgenerator.dart';

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
   File? _imageFile;
  Uint8List? _imageBytes;
  File? _selectedImage;
  String? _imageUrl;
  final List<Map<String, dynamic>> _certifications = [];
  String? _dateError;
  String? _expirationDateError;
  Size? _imageSize;
  String? _imageName;
  File? _driverLicenseFile;
  bool _isLoading = true;

  Future<Map<String, dynamic>?> getDoc(File? file, String type) async {
  if (file == null) return null;
   

  try {
    final originalSize = await file.length();
    print('Taille originale: ${originalSize} bytes');

    // Rejeter directement les fichiers > 5 Mo (trop longs à compresser)
    if (originalSize > 50 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fichier trop volumineux (max 5 Mo)")),
      );
      return null;
    }

    Uint8List compressedBytes = await file.readAsBytes();
    bool isImage = file.path.toLowerCase().endsWith('.jpg') || 
                   file.path.toLowerCase().endsWith('.jpeg') || 
                   file.path.toLowerCase().endsWith('.png');

    if (isImage) {
      int quality = 50; // Commencez avec une qualité plus basse
      int maxAttempts = 4;
      int targetSize = 90 * 1024; // Cible 90 Ko pour rester sous 100 Ko

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        compressedBytes = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minHeight: 600,  // Réduire la résolution
          minWidth: 600,
          quality: quality,
        );

        print('Tentative ${attempt + 1}: ${compressedBytes.lengthInBytes} bytes');

        // Si la taille est acceptable, sortir de la boucle
        if (compressedBytes.lengthInBytes <= targetSize) break;

        // Réduire la qualité pour la prochaine tentative
        quality -= 15;
        if (quality < 20) quality = 20; // Qualité minimale de 20%
      }
    }

    // Vérification finale (ne pas dépasser 100 Ko)
    if (compressedBytes.lengthInBytes > 102400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le fichier est trop lourd après compression")),
      );
      return null;
    }

    return {
      "type": type,
      "file": base64Encode(compressedBytes),
      "name": file.path.split('/').last,
      "note": "",
    };
  } catch (e) {
    print('Erreur de compression: $e');
    return null;
  }
}
Future<void> _pickDocument(String type) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );
  
  if (result != null && result.files.isNotEmpty) {
    PlatformFile file = result.files.first;
    if (!kIsWeb && file.path != null) {
      final newFile = File(file.path!);
      if (newFile.lengthSync() > 50 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Le fichier est trop volumineux (max 5MB)")),
        );
        return;
      }

      
      setState(() {
        switch (type) {
          case 'driver_license':
            _driverLicenseFile = newFile;
            break;
         
        }
      });
    }
  }
}

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  // @override
  // void dispose() {
  //   titleController.dispose();
  //   organizationController.dispose();
  //   descriptionController.dispose();
  //   dateController.dispose();
  //   expirationDateController.dispose();
  //   _animationController.dispose();
  //   super.dispose();
  // }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        setState(() {
          _imageUrl = pickedFile.path;
          _imageName = pickedFile.name;
          _imageSize = null;
        });
      } else {
        final imageFile = File(pickedFile.path);
        final image = await decodeImageFromList(await imageFile.readAsBytes());
        
        setState(() {
          _selectedImage = imageFile;
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());
          _imageName = pickedFile.path.split('/').last;
        });
      }
    }
  }

  bool _validateDates() {
    final date = dateController.text.trim();
    final expirationDate = expirationDateController.text.trim();
    
    if (date.isEmpty) {
      setState(() => _dateError = 'Please select a date');
      return false;
    }
    
    if (expirationDate.isEmpty) {
      setState(() => _expirationDateError = 'Please select an expiration date');
      return false;
    }
    
    final dateTime = DateTime.parse(date);
    final expirationDateTime = DateTime.parse(expirationDate);
    
    if (expirationDateTime.isBefore(dateTime)) {
      setState(() => _expirationDateError = 'Expiration date must be after the issue date');
      return false;
    }
    
    if (expirationDateTime.isBefore(DateTime.now())) {
      setState(() => _expirationDateError = 'This certification has already expired');
      return false;
    }
    
    setState(() {
      _dateError = null;
      _expirationDateError = null;
    });
    return true;
  }

  void _addCertification() {
    final title = titleController.text.trim();
    final organization = organizationController.text.trim();
    final description = descriptionController.text.trim();
    final date = dateController.text.trim();
    final expirationDate = expirationDateController.text.trim();

    if (!_validateDates()) {
      return;
    }

    if (title.isEmpty || organization.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields (title and organization)!')),
      );
      return;
    }

    Map<String, dynamic> certificationData = {
      'title': title,
      'organization': organization,
      'description': description,
      'date': date,
      'expirationDate': expirationDate,
      'isExpired': DateTime.parse(expirationDate).isBefore(DateTime.now()),
      'imagePath': _selectedImage?.path ?? _imageUrl,
      'imageName': _imageName ?? 'No image',
      'form_type': 'Certification',
    };

    setState(() {
      _certifications.add(certificationData);
      PdfGenerator.bigList.add(certificationData);
    });

    // Add certification data to BigList
    Map<String, dynamic> bigListItem = Map<String, dynamic>.from(certificationData);
    bigListItem['form_type'] = 'Certification';
    PdfGenerator.BigList.add(bigListItem);
    print('BIGLIST after certification: ${PdfGenerator.bigList}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Certification added successfully!')),
    );

    _resetForm();
  }
  void _goToNextPage() {
    if (_certifications.isEmpty) {
      // Show error
      return;
    }

    print('BIGLIST before next screen: ${PdfGenerator.bigList}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLanguageScreen(),
      ),
    );
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
      _imageSize = null;
      _imageName = null;
      _dateError = null;
      _expirationDateError = null;
    });
  }

  Future<void> _pickDate(TextEditingController controller, {DateTime? initialDate}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      controller.text = pickedDate.toIso8601String().split('T')[0];
      _validateDates();
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
          _buildDescriptionField(),
          const SizedBox(height: 15),
          _buildDateField(dateController, 'Date', errorText: _dateError),
          const SizedBox(height: 15),
          _buildDateField(expirationDateController, 'Expiration Date', errorText: _expirationDateError),
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
      child: Column(
        children: [
          GestureDetector(
          onTap: () => _pickDocument('driver_license'),
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.teal[200]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _driverLicenseFile != null || _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : Image.file(_driverLicenseFile!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: Colors.teal[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Upload Driver License',
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to select file',
                        style: TextStyle(
                          color: Colors.teal[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
          if (_imageSize != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Image: $_imageName • ${_imageSize!.width.toInt()}x${_imageSize!.height.toInt()} pixels',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
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

  Widget _buildDescriptionField() {
    return TextField(
      controller: descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Description (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pickDate(
            controller,
            initialDate: controller.text.isNotEmpty ? DateTime.parse(controller.text) : null,
          ),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                errorText: errorText,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No certifications added yet',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _certifications.length,
      itemBuilder: (context, index) {
        final cert = _certifications[index];
        final isExpired = cert['isExpired'] as bool;
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: isExpired ? Colors.red[50] : null,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: (cert['imagePath'] != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb && cert['imagePath'] is String
                              ? Image.network(
                                  cert['imagePath']!,
                                  fit: BoxFit.cover,
                                  width: 70,
                                  height: 70,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                                )
                              : cert['imagePath'] is String
                                ? Image.file(
                                    File(cert['imagePath']!),
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 70,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                                  )
                                : const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                        )
                      : const Icon(Icons.description, size: 30, color: Colors.teal),
                ),
                title: Text(
                  cert['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cert['organization']}'),
                    Text('Issued: ${cert['date']}'),
                    Text('Expires: ${cert['expirationDate']}'),
                    if (isExpired)
                      const Text(
                        'EXPIRED',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _certifications.removeAt(index);
                    });
                  },
                ),
              ),
              if (cert['description']?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    cert['description'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  cert['imageName'] != null && cert['imageName'] != 'No image'
                    ? 'Image: ${cert['imageName']}${cert['imageSize'] != null ? ' • ${cert['imageSize'].width.toInt()}x${cert['imageSize'].height.toInt()} px' : ''}'
                    : 'No image attached',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFreeCertificateButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
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
        onPressed: _goToNextPage,
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