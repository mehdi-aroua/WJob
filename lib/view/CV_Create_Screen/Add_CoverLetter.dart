import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:flutter_wjob/api_service.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:flutter_wjob/classes/pdfgenerator.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:flutter_wjob/view/filtre/jobmatching.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddCoverLetterScreen extends StatefulWidget {
  const AddCoverLetterScreen({Key? key}) : super(key: key);

  @override
  State<AddCoverLetterScreen> createState() => _AddCoverLetterScreenState();
}

class _AddCoverLetterScreenState extends State<AddCoverLetterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _coverLetterController = TextEditingController();
  final List<String> _coverLetters = [];

  late final AnimationController _animationController;
  bool _showChatBot = false;
  bool _isLoading = true;
  List<JobItem> jobList = [];
  Map<String, dynamic>? cvAnalysis;
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
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
     
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

  @override
  void dispose() {
    _coverLetterController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  void _addCoverLetter() {
    final coverLetter = _coverLetterController.text.trim();

    if (coverLetter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a cover letter!')),
      );
      return;
    }

    setState(() {
      _coverLetters.add(coverLetter);
    });

    // Add cover letter to BigList
    PdfGenerator.bigList.add({
      'cover_letter': coverLetter,
      'form_type': 'Cover Letter',
      'date_added': DateTime.now().toString(),
    });

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _coverLetterController.clear();
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
          _buildCoverLetterField(),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 30),
          _buildCoverLetterList(),
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
        'Add Cover Letter',
        style: TextStyle(color: Colors.teal, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCoverLetterField() {
    return TextField(
      controller: _coverLetterController,
      maxLines: 10,
      decoration: InputDecoration(
        hintText: 'Write your cover letter here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _addCoverLetter,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Cover Letter', style: TextStyle(color: Colors.white)),
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

  Widget _buildCoverLetterList() {
    if (_coverLetters.isEmpty) {
      return const Center(child: Text('No cover letters added yet.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _coverLetters.length,
      itemBuilder: (context, index) {
        final coverLetter = _coverLetters[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(coverLetter),
          ),
        );
      },
    );
  }
  
  Widget _buildNextButton() {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _generateAndDownloadPDF,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Download CV',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () async {
            if (_coverLetters.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add a cover letter first!'),
                ),
              );
              return;
            }
             showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                        ),
                        const SizedBox(height: 15),
                        const Text('Loading jobs...'),
                      ],
                    ),
                  ),
                );
              },
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
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

Future<void> _generateAndDownloadPDF() async {
  try {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text("Generating PDF...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    // Generate the PDF with the current bigList data
    print('Starting PDF generation with ${PdfGenerator.bigList.length} items');
    final pdfResult = await PdfGenerator.generateCV(PdfGenerator.bigList);
    
    if (!pdfResult.success || pdfResult.bytes == null) {
      throw Exception(pdfResult.errorMessage ?? 'Unknown error generating PDF');
    }
    
    print('PDF generation completed successfully, ${pdfResult.bytes!.length} bytes generated');
    
    // Try to extract CV data (but don't fail the whole process if this fails)
    Map<String, dynamic>? extractedData;
    final apiService = ApiService();
    
    try {
      // First try bytes-based approach
      try {
        print('Using bytes-based approach to extract CV');
        extractedData = await apiService.extractCvFromBytes(pdfResult.bytes!);
        print('Extracted CV data (bytes): $extractedData');
      } catch (bytesError) {
        print('Error with bytes extraction: $bytesError');
        
        // Fall back to file-based approach if bytes approach fails
        try {
          print('Attempting file-based extraction');
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/temp_cv.pdf');
          await file.writeAsBytes(pdfResult.bytes!);
          print("Temporary file created at: ${file.path}");
          
          extractedData = await apiService.extractCv(file);
          print('Extracted CV data (file): $extractedData');
          
          // Clean up the temp file
          await file.delete();
        } catch (fileError) {
          print('Error with file extraction: $fileError');
          // Don't throw here - we'll just continue without extracted data
        }
      }
    } catch (e) {
      print('Error in CV extraction: $e');
      // Show error but continue with PDF preview
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not extract CV data: ${e.toString()}')),
      );
    }
    
    // Close loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show success dialog with options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("PDF Generated Successfully"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your CV has been generated in memory"),
            SizedBox(height: 15),
            Text("What would you like to do next?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Open the PDF file using the printing package
                await Printing.layoutPdf(
                  onLayout: (PdfPageFormat format) async => pdfResult.bytes!,
                );
              } catch (e) {
                print('Error opening PDF: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error opening PDF: ${e.toString()}")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: Text("Preview PDF"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Share the PDF file
                await Printing.sharePdf(
                  bytes: pdfResult.bytes!,
                  filename: 'my_cv.pdf',
                );
              } catch (e) {
                print('Error sharing PDF: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error sharing PDF: ${e.toString()}")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
            child: Text("Share PDF"),
          ),
        ],
      ),
    );
  } catch (e) {
    // Close loading dialog if it's still open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    print('Error in PDF generation process: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error generating PDF: ${e.toString()}"),
        duration: Duration(seconds: 10),
      ),
    );
  }
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
}
