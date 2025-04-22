import 'package:flutter/material.dart';
import 'package:flutter_wjob/api_service.dart';
import 'package:flutter_wjob/widgets/chatbot_widget.dart';
import 'package:flutter_wjob/view/login_screen/signup_screen.dart';
import 'package:flutter_wjob/view/welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Constants for styles
  static const _primaryColor = Colors.teal;
  static const _animationDuration = Duration(milliseconds: 800);
  static const _padding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 40);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);
  try {
    final response = await ApiService().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
      
      _navigateToWelcome();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primaryColor),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Reset'),
        content: const Text(
          'Enter your email to receive a password reset link.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset email sent')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  void _navigateToWelcome() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _padding,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const _Logo(),
                    const _LoginTitle(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email', Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (value.length < 8) {
                          return 'Email must be at least 8 characters';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration('Password', Icons.lock_outline),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 8) {
                          return 'Password too short (8 characters min.)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildLoginButton(),
                    TextButton(
                      onPressed: _isLoading ? null : _showForgotPasswordDialog,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: _primaryColor),
                      ),
                    ),
                    const _OrSeparator(),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton(
          backgroundColor: _primaryColor,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(10),
                child: const ChatBotWidget(),
              ),
            );
          },
          child: const Icon(Icons.chat, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Log in',
                style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: _isLoading ? null : _navigateToSignUp,
      child: const Text(
        'Create an account',
        style: TextStyle(color: _primaryColor),
      ),
    );
  }
}

// Internal Widgets
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Image.asset(
        'lib/assets/logo.png',
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.account_circle, size: 80),
      ),
    );
  }
}

class _LoginTitle extends StatelessWidget {
  const _LoginTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            text: 'L',
            style: TextStyle(
              color: _LoginScreenState._primaryColor,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'ogin',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 38,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Welcome back, log in to continue",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _OrSeparator extends StatelessWidget {
  const _OrSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('OR'),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
}