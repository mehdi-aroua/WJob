import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Pour sélectionner des fichiers
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_wjob/api_service.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:flutter_wjob/view/filtre/jobmatching.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart'; // Pour le chatbot
import 'package:flutter_wjob/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Pour le bouton personnalisé

class UploadCVScreen extends StatefulWidget {
  const UploadCVScreen({Key? key}) : super(key: key);

  @override
  State<UploadCVScreen> createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen>
    with SingleTickerProviderStateMixin {
   File? _imageFile;
  Uint8List? _imageBytes;
  bool _showChatBot = false;
  File? _insuranceFile;
  late AnimationController _animationController;
  File? _driverLicenseFile;
  bool _isLoading = true;
  List<JobItem> jobList = [];
  Map<String, dynamic>? cvAnalysis;


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




  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }
  String? selectedDatePosted;
  final random = Random();

  DateTime generateRandomDate(String datePostedFilter) {
    final now = DateTime.now();
    

    // Create different ranges based on the filter
    switch (datePostedFilter) {
      case 'Today':
        return now.subtract(Duration(minutes: random.nextInt(60 * 24))); 
      case 'Last 3 days':
        return now.subtract(Duration(days: random.nextInt(3)));
      case 'Last 7 days':
        return now.subtract(Duration(days: random.nextInt(7)));
      case 'Last 30 days':
        return now.subtract(Duration(days: random.nextInt(30)));
      default:
        return now.subtract(Duration(days: random.nextInt(30)));
    }
  }
  String formatDate(DateTime date, {bool isTimeFormat = false}) {
  if (isTimeFormat) {
      return DateFormat('HH:mm').format(date); 
    } else {
      return DateFormat('MMM dd').format(date); 
    }
  }

  String getTimeDifference(DateTime jobDate, {bool isTimeFormat = false}) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(jobDate);

    if (difference.inDays < 1) {
      return isTimeFormat ? formatDate(jobDate, isTimeFormat: true) : 'Today';
    } else if (difference.inDays == 1) {
      return isTimeFormat ? formatDate(jobDate, isTimeFormat: true) : 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

   Future<void> _fetchJobs() async {
    try {
      
      final apiService = ApiService();
      final response = await apiService.matchJobs();
      final datePosted = generateRandomDate(selectedDatePosted ?? 'Last 30 days');

                  final timeAgo = getTimeDifference(datePosted, isTimeFormat: selectedDatePosted != null && selectedDatePosted == 'Today');
      setState(() {
        cvAnalysis = response['cv_analysis'];
        jobList = (response['best_jobs'] as List)
            .map((job) => JobItem(
                  
                  title: job['title'] ?? 'No title',
                  company: job['company'] ?? 'No company',
                  location: job['location'] ?? 'No location',
                  description: job['description'] ?? 'No description available',
                  salary: job['salary'] ?? 'Salary not specified',
                  experience: job['experience'] ?? 'Experience not specified',
                  datePosted: job['date_posted'] ?? 'Date not available',
                  link: job['link'] ?? '',
                  timeAgo: timeAgo,
                  icon: Icons.business,
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jobs: ${e.toString()}')),
      );
    }
  }
  
  void _sendFile() async {
    // Check if a file was selected
    if (_driverLicenseFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF file first!')),
      );
      return;
    }

    // Check if the file is a PDF
    final fileName = _driverLicenseFile!.path.toLowerCase();
    if (!fileName.endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF file!')),
      );
      return;
    }

    final apiService = ApiService();
    
    // Store the navigator context to ensure we can pop the dialog later
    NavigatorState? navigator;
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          // Capture the navigator context
          navigator = Navigator.of(context);
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Call extractCv with the PDF file
      try {
        final extractedData = await apiService.extractCv(_driverLicenseFile!);
        print('Extracted CV data: $extractedData');
      } catch (e, stackTrace) {
        print('Erreur lors de l\'extraction du CV : $e');
        print('StackTrace : $stackTrace');
        // Tu peux aussi afficher un SnackBar ou dialog ici pour informer l'utilisateur
      }


      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV processed successfully!'),
        backgroundColor: Colors.green,),
      );
     

      await _fetchJobs();
      await Future.delayed(const Duration(seconds: 30));
      Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Jobmatching(jobs: jobList),
              ),
            );
          
    } catch (e) {
      Navigator.of(context).pop();
      print('Error processing CV: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing CV: ${e.toString()}')),
      );
    } 
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
  
 Widget _buildContent() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Section
        Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Optimize Your Career',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your CV to get personalized job matches',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Upload Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Upload Icon Area
                GestureDetector(
                  onTap: () => _pickDocument('driver_license'),
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.teal[200]!,
                        width: 2,
                        style: BorderStyle.solid
                      ),
                    ),
                    child: _driverLicenseFile != null || _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : Image.file(_driverLicenseFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 40,
                                color: Colors.teal[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload',
                                style: TextStyle(
                                  color: Colors.teal[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // File Info
                if (_driverLicenseFile != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.teal[400],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _driverLicenseFile!.path.split('/').last,
                            style: TextStyle(
                              color: Colors.teal[800],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_driverLicenseFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        
        ),
        
        const Spacer(),
        
        // Action Button
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: ElevatedButton(
            onPressed: _driverLicenseFile != null ? _sendFile : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20),
                SizedBox(width: 8),
                Text(
                  'Analyze My CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
