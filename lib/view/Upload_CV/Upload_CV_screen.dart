import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Pour sélectionner des fichiers
import 'package:flutter_wjob/widgets/chatbot_widget.dart'; // Pour le chatbot
import 'package:flutter_wjob/widgets/custom_button.dart'; // Pour le bouton personnalisé

class UploadCVScreen extends StatefulWidget {
  const UploadCVScreen({Key? key}) : super(key: key);

  @override
  State<UploadCVScreen> createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen>
    with SingleTickerProviderStateMixin {
  File? _cvFile;
  bool _showChatBot = false;
  Uint8List? _imageBytes;
  File? _insuranceFile;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
 Future<void> _pickDocument(String type) async {
  print('[DEBUG] Picking document of type: $type'); // Track file picker call

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom, 
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    print('[DEBUG] Selected file: ${file.name}, path: ${file.path}, bytes: ${file.bytes != null}'); // Log file details

    setState(() {
      if (!kIsWeb && file.path != null) {
        switch (type) {
          case 'cv':
            _insuranceFile = File(file.path!);
            print('[DEBUG] _insuranceFile set: ${_insuranceFile?.path}'); // Confirm file assignment
            break;
        }
      } else if (kIsWeb) {
        _imageBytes = file.bytes;
        print('[DEBUG] _imageBytes set (Web): ${_imageBytes != null}'); // Confirm bytes assignment
      }
    });
  } else {
    print('[DEBUG] User cancelled file picker'); // Check if user cancelled
  }
}



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
      });
    }
  }

  void _removeFile() {
    setState(() {
      _cvFile = null;
    });
  }

  void _sendFile() {
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file first!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CV sent successfully!')),
    );

    setState(() {
      _cvFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(),
            _buildChatBotButton(),
            if (_showChatBot) _buildChatBot(),
          ],
        ),
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
        tooltip: 'Back',
      ),
      title: const Text(
        'Upload Your CV',
        style: TextStyle(color: Colors.teal, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
   Future<void> _pickImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']
    );
    
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        if (kIsWeb) {
          _imageBytes = file.bytes;
        } else {
          _cvFile = File(file.path!);
        }
      });
    }
  }
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Upload your CV (PDF or Image)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildFilePicker(),
          const SizedBox(height: 30),
          if (_cvFile != null) _buildFilePreview(),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Send',
            icon: Icons.send,
            onPressed: _sendFile,
           
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker() {
  print('[DEBUG] Building File Picker Widget'); // Track widget rebuilds

  return GestureDetector(
    onTap: () async {
      print('[DEBUG] Tapped on File Picker'); // Check if tap is registered
      await _pickDocument('cv');
    },
    child: Container(
      height: 104,
      width: 104,
      color: Colors.grey[300],
      child: _insuranceFile != null || _imageBytes != null
          ? _imageBytes != null
              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
              : Image.file(_insuranceFile!, fit: BoxFit.cover)
          : Center(
              child: SizedBox(
                height: 27,
                width: 36,
                child: Image.asset(
                  "assets/logo.png",
                  errorBuilder: (context, error, stackTrace) {
                    print('[ERROR] Failed to load image: $error'); // Debug image loading
                    return const Icon(Icons.error, color: Colors.red);
                  },
                ),
              ),
            ),
    ),
  );
}

  Widget _buildFilePreview() {
    final fileExtension = _cvFile!.path.split('.').last.toLowerCase();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (fileExtension == 'pdf')
                const Icon(Icons.picture_as_pdf, size: 60, color: Colors.teal)
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _cvFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                _cvFile!.path.split('/').last,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _removeFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Remove File', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
          ],
        ),
        child: const ChatBotWidget(),
      ),
    );
  }
}
