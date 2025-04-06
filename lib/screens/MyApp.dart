import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Initializing LoginScreen");  // Log pour debug
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );  // Suppression de repeat pour éviter une boucle infinie
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    print("Form submitted");  // Debug

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building LoginScreen");  // Debug
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Image.asset(
                    'lib/assets/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, size: 80),
                  ),
                ),
                const _LoginTitle(),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email', Icons.email_outlined),
                  validator: (value) => value?.isEmpty ?? true 
                      ? 'Veuillez entrer votre email' 
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Mot de passe', Icons.lock_outline),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Veuillez entrer votre mot de passe'
                      : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Se connecter', style: TextStyle(fontSize: 16)),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : () => _showForgotPasswordDialog(context),
                  child: const Text('Mot de passe oublié ?', style: TextStyle(color: Colors.teal)),
                ),
                const _OrSeparator(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.teal),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : () => _navigateToSignUp(context),
                  child: const Text('Créer un compte', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _AnimatedChatButton(controller: _animationController),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialisation'),
        content: const Text('Entrez votre email pour réinitialiser votre mot de passe'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email envoyé')),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _navigateToSignUp(BuildContext context) {
    print("Navigating to SignUp"); // Debug
    // Vérifier que la navigation n'est pas en boucle infinie
    if (!Navigator.of(context).canPop()) {
      // Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
    }
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
              color: Colors.teal,
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
        const SizedBox(height: 30),
        const Text(
          "Let's get you started",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _OrSeparator extends StatelessWidget {
  const _OrSeparator();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 30),
        Row(children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('OU'),
          ),
          Expanded(child: Divider()),
        ]),
        SizedBox(height: 30),
      ],
    );
  }
}

class _AnimatedChatButton extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedChatButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showChat(context),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  void _showChat(BuildContext context) {
    print("Chat button pressed"); // Debug
  }
}
