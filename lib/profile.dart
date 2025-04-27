
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _imageFile;
  Uint8List? _imageBytes;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _fingerprintEnabled = true;
  bool _faceIdEnabled = false;
  bool _isLoading = true;
  String? _profilePicUrl;
  Future<dynamic>? _userProfile;

  Uint8List? fileBytes;

  @override
  void initState() {
    super.initState();
    // Initialize _userProfile here with your actual data fetching logic
    _userProfile = _fetchUserProfile();
  }

  Future<dynamic> _fetchUserProfile() async {
    // Replace this with your actual profile fetching logic
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return {
      'profile_pic': _profilePicUrl,
      'name': 'John Doe',
      'phone': '1234567890',
      'email': 'john.doe@example.com',
    };
  }

  ImageProvider getImageProvider(String? imageUrl) {
    if (fileBytes != null) {
      return MemoryImage(fileBytes!);
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      return AssetImage('assets/Icone/avatar.png');
    }

    Uri uri = Uri.parse(imageUrl);
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return NetworkImage(imageUrl);
    }
    if (uri.scheme == 'file') {
      return FileImage(File(uri.toFilePath()));
    }
    return AssetImage('assets/Icone/avatar.png');
  }

  Future<void> _pickImageFromGallery() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        if (kIsWeb) {
          _imageBytes = file.bytes;
        } else {
          _imageFile = File(file.path!);
        }
      });
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Language',
            style: TextStyle(fontSize: screenWidth * 0.05),
          ),
         
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int _rating = 3;
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 122,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.1, -0.1),
              end: Alignment(1.0, 1.1),
              colors: [
                Color(0xFF006AFF),
                Color(0xFF1CA7C2),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<dynamic>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final profile = snapshot.data;
            _nameController.text = profile['name'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
            _emailController.text = profile['email'] ?? '';
            
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 14),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: getImageProvider(profile['profile_pic']),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImageFromGallery,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildStarRating(_rating),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration:
                          InputDecoration(border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      decoration:
                          InputDecoration(border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration:
                          InputDecoration(border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration:
                          InputDecoration(border: OutlineInputBorder(),hintText: 'new password',),
                    ),
                    SizedBox(height: 20),
                    _buildSwitch( 'Notification', _notificationsEnabled,
                        (val) => setState(() => _notificationsEnabled = val)),
                    _buildSwitch( 'Fingerprint', _fingerprintEnabled,
                        (val) => setState(() => _fingerprintEnabled = val)),
                    _buildSwitch( 'Face ID', _faceIdEnabled,
                        (val) => setState(() => _faceIdEnabled = val)),
                    SizedBox(height: 20),
                    _buildListTile(
                      context,
                      icon: Icons.language,
                      title:  'Language',
                      screenWidth: screenWidth,
                      onTap: () => _showLanguageDialog(context),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: SizedBox(
                              width: 70,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_back,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                          
                         
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  Widget _buildSwitch(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
     
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required double screenWidth,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color(0xffDAA520), size: screenWidth * 0.06),
      title: Text(title,
          style: TextStyle(
              fontSize: screenWidth * 0.045,)),
      trailing: Icon(Icons.chevron_right,
          color: Color(0xff888888), size: screenWidth * 0.06),
      onTap: onTap,
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Image.asset(
            index < rating
                ? 'assets/Icone/Fichier18.png'
                : 'assets/Icone/Fichier19.png',
            width: 24,
            height: 24,
          ),
        );
      }),
    );
  }
}