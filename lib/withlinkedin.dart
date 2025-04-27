import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_wjob/api_service.dart';
import 'package:flutter_wjob/classes/class_job_item.dart';
import 'package:flutter_wjob/view/filtre/jobmatching.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:intl/intl.dart';

class WithLinkedIn extends StatefulWidget {
  const WithLinkedIn({Key? key}) : super(key: key);

  @override
  State<WithLinkedIn> createState() => _WithLinkedInState();
}

class _WithLinkedInState extends State<WithLinkedIn> with SingleTickerProviderStateMixin {
  final TextEditingController _linkedInController = TextEditingController();
  final ApiService apiService = ApiService();
  List<JobItem> jobList = [];
  bool _isLoading = false;
  late final AnimationController _animationController;
  bool _showChatBot = false;
  String? selectedDatePosted;
  final random = Random();

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
    _linkedInController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  DateTime _generateRandomDate(String datePostedFilter) {
    final now = DateTime.now();
    
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

  String _formatTimeDifference(DateTime jobDate) {
    final difference = DateTime.now().difference(jobDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(jobDate);
    }
  }

  bool _isValidLinkedInUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('linkedin.com');
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleSend() async {
    if (_isLoading) return;
    
    final profileUrl = _linkedInController.text.trim();
    if (!_isValidLinkedInUrl(profileUrl)) {
      _showSnackBar('Please enter a valid LinkedIn URL');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      _showSnackBar('Analyzing LinkedIn profile...');
      await apiService.scrapeLinkedInProfile(profileUrl);

      _showSnackBar('Finding matching jobs...');
      final matchedJobs = await apiService.matchJobsLinkedIn();
      
      final jobs = matchedJobs.map((job) {
        final randomDate = _generateRandomDate(selectedDatePosted ?? 'Last 30 days');
        return JobItem(
          title: job['title'] ?? 'No title',
          company: job['company'] ?? 'No company',
          location: job['location'] ?? 'No location',
          description: job['description'] ?? 'No description available',
          salary: job['salary'] ?? 'Salary not specified',
          experience: job['experience'] ?? 'Experience not specified',
          datePosted: job['date_posted'] ?? 'Date not available',
          link: job['link'] ?? '',
          timeAgo: _formatTimeDifference(randomDate),
          icon: Icons.business,
        );
      }).toList();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Jobmatching(jobs: jobs),
        ),
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
        children: [
          const SizedBox(height: 10),
          const Text(
            'Add LinkedIn URL',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _linkedInController,
            decoration: InputDecoration(
              hintText: 'https://linkedin.com/in/your-profile',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSend,
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Icon(Icons.send, color: Colors.white),
            label: const Text('Send', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
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
            if (_showChatBot) _buildChatBot(),
            _buildChatBotButton(),
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
        onPressed: () {
          setState(() => _showChatBot = !_showChatBot);
          _showChatBot 
            ? _animationController.forward() 
            : _animationController.reverse();
        },
        child: ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          ),
          child: Icon(
            _showChatBot ? Icons.close : Icons.chat,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBot() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
            ),
          ]
          ),
          child: const ChatBotWidget(),
          
        ),
      ),
    );
  }
}