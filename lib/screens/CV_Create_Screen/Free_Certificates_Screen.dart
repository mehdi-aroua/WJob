import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour ouvrir des liens web
import 'package:flutter_wjob/widgets/chatbot_widget.dart';

class FreeCertificatesScreen extends StatefulWidget {
  const FreeCertificatesScreen({Key? key}) : super(key: key);

  @override
  State<FreeCertificatesScreen> createState() => _FreeCertificatesScreenState();
}

class _FreeCertificatesScreenState extends State<FreeCertificatesScreen>
    with SingleTickerProviderStateMixin {
  // Liste des sites web avec leurs noms et URL
  final List<Map<String, String>> _certificateSites = const [
    {
      'name': 'Coursera',
      'url': 'https://www.coursera.org/',
    },
    {
      'name': 'edX',
      'url': 'https://www.edx.org/',
    },
    {
      'name': 'Udemy',
      'url': 'https://www.udemy.com/',
    },
    {
      'name': 'Khan Academy',
      'url': 'https://www.khanacademy.org/',
    },
    {
      'name': 'FutureLearn',
      'url': 'https://www.futurelearn.com/',
    },
    {
      'name': 'Google Digital Garage',
      'url': 'https://learndigital.withgoogle.com/digitalgarage/',
    },
    {
      'name': 'Microsoft Learn',
      'url': 'https://learn.microsoft.com/',
    },
    {
      'name': 'LinkedIn Learning',
      'url': 'https://www.linkedin.com/learning/',
    },
  ];

  late final AnimationController _animationController;
  bool _showChatBot = false;

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

  // Fonction pour ouvrir une URL dans le navigateur
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
        'Free Certificates',
        style: TextStyle(color: Colors.teal, fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _certificateSites.length,
      itemBuilder: (context, index) {
        final site = _certificateSites[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: const Icon(Icons.school, color: Colors.teal),
            title: Text(
              site['name']!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward, color: Colors.teal),
            onTap: () => _launchURL(site['url']!),
          ),
        );
      },
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
        child: const ChatBotWidget(), // Remplacez par votre widget de chatbot
      ),
    );
  }
}