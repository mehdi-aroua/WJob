import 'package:flutter/material.dart';
import 'package:flutter_wjob/screens/CV_Create_Screen/Add_CoverLetter.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';


class AddSocialMediaScreen extends StatefulWidget {
  const AddSocialMediaScreen({Key? key}) : super(key: key);

  @override
  State<AddSocialMediaScreen> createState() => _AddSocialMediaScreenState();
}

class _AddSocialMediaScreenState extends State<AddSocialMediaScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final List<Map<String, String>> _socialMediaLinks = [];

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
    _linkedInController.dispose();
    _githubController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() => _showChatBot = !_showChatBot);
    _showChatBot ? _animationController.forward() : _animationController.reverse();
  }

  void _addSocialMedia() {
    final linkedIn = _linkedInController.text.trim();
    final github = _githubController.text.trim();
    final twitter = _twitterController.text.trim();
    final facebook = _facebookController.text.trim();
    final instagram = _instagramController.text.trim();

    if (linkedIn.isEmpty &&
        github.isEmpty &&
        twitter.isEmpty &&
        facebook.isEmpty &&
        instagram.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one social media link!')),
      );
      return;
    }

    setState(() {
      _socialMediaLinks.add({
        'LinkedIn': linkedIn,
        'GitHub': github,
        'Twitter': twitter,
        'Facebook': facebook,
        'Instagram': instagram,
      });
    });

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _linkedInController.clear();
      _githubController.clear();
      _twitterController.clear();
      _facebookController.clear();
      _instagramController.clear();
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
          _buildTextField(_linkedInController, 'LinkedIn URL'),
          const SizedBox(height: 15),
          _buildTextField(_githubController, 'GitHub URL'),
          const SizedBox(height: 15),
          _buildTextField(_twitterController, 'Twitter URL'),
          const SizedBox(height: 15),
          _buildTextField(_facebookController, 'Facebook URL'),
          const SizedBox(height: 15),
          _buildTextField(_instagramController, 'Instagram URL'),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 30),
          _buildSocialMediaList(),
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
        'Add Social Media Links',
        style: TextStyle(color: Colors.teal, fontSize: 24, fontWeight: FontWeight.bold),
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _addSocialMedia,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Links', style: TextStyle(color: Colors.white)),
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

  Widget _buildSocialMediaList() {
    if (_socialMediaLinks.isEmpty) {
      return const Center(child: Text('No social media links added yet.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _socialMediaLinks.length,
      itemBuilder: (context, index) {
        final links = _socialMediaLinks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('LinkedIn: ${links['LinkedIn'] ?? 'Not provided'}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GitHub: ${links['GitHub'] ?? 'Not provided'}'),
                Text('Twitter: ${links['Twitter'] ?? 'Not provided'}'),
                Text('Facebook: ${links['Facebook'] ?? 'Not provided'}'),
                Text('Instagram: ${links['Instagram'] ?? 'Not provided'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_socialMediaLinks.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add at least one social media link before continuing.'),
              ),
            );
            return;
          }

         Navigator.push(context, MaterialPageRoute(builder: (context) => AddCoverLetterScreen()));
        },
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