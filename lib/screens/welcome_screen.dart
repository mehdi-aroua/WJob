import 'package:flutter/material.dart';
import 'package:flutter_wjob/screens/create_cv_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/chatbot_widget.dart';
import '../widgets/menu_drawer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _showChatBot = false; // ✅ Cohérence du nom
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose(); // ✅ Bonne pratique
    super.dispose();
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
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(context),

            if (_showChatBot)
              const ChatBotWidget(),

            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.teal,
                onPressed: _toggleChat,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'W',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'elcome',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 38,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Let's get you started",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'Create a new CV',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Bouton Créer CV
              CustomButton(
                text: 'Create your own CV',
                icon: Icons.description_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateCVScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),

              // Bouton Build avec IA
              CustomButton(
                text: 'Build with AI',
                icon: Icons.auto_fix_high_outlined,
                onPressed: () {
                  // Fonctionnalité future
                },
              ),
              const SizedBox(height: 40),

              const Text(
                'Upload Existing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Bouton LinkedIn
              CustomButton(
                text: 'LinkedIn',
                icon: Icons.link,
                onPressed: () {
                  // Fonctionnalité future
                },
              ),
              const SizedBox(height: 15),

              // Bouton Upload CV
              CustomButton(
                text: 'Upload your resume',
                icon: Icons.upload_file_outlined,
                onPressed: () {
                  // Fonctionnalité future
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          '../assets/logo.png',
          fit: BoxFit.contain,
          height: 40,
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.grey),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }
}
