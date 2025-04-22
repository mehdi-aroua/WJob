import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({Key? key}) : super(key: key);

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final List<Map<String, String>> _messages = [
    {"text": "Bonjour ! Comment puis-je vous aider ?", "sender": "bot"}
  ];
  final TextEditingController _chatController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final userMessage = _chatController.text.trim();
    if (userMessage.isEmpty) return;

    _chatController.clear();

    setState(() {
      _messages.add({"text": userMessage, "sender": "user"});
      _messages.add({"text": "🤖 Je réfléchis...", "sender": "bot"});
      _isLoading = true;
    });

    try {
      final botResponse = await _fetchBotResponse(userMessage);

      setState(() {
        _messages.removeLast(); // Supprime "Je réfléchis..."
        _messages.add({"text": botResponse, "sender": "bot"});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({
          "text":
              "❌ Une erreur s'est produite. Vérifie ta connexion ou ta clé API.",
          "sender": "bot"
        });
        _isLoading = false;
      });
      print('Erreur API : $e');
    }
  }

  Future<String> _fetchBotResponse(String message) async {
    const apiKey = '039b84323c64f31dca20eaa6efbbf6454e4b5cd5f34eb47b50aefdd15902d096'; // Remplace ici avec ta clé

    final url = Uri.parse('https://api.together.xyz/v1/chat/completions');

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": "mistralai/Mistral-7B-Instruct-v0.2",
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": message}
      ],
      "temperature": 0.7,
      "top_p": 0.9,
      "max_tokens": 512
    });

    final response = await http.post(url, headers: headers, body: body);

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Erreur API: ${response.body}');
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 20,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "ChatBot",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.teal.shade100
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(message['text'] ?? ''),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: "Écris un message...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
