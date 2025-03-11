import 'package:flutter/material.dart';
import 'package:wjob/api_service.dart';
import 'package:wjob/cammon/color_extension.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isLoading = false; 
  void _sendMessage() async {
    
    if (_controller.text.isEmpty) return;
    FocusScope.of(context).requestFocus(FocusNode());
    
    // Add the user's message to the chat history
    setState(() {
      _messages.add("You: ${_controller.text}");
      _isLoading = true; 
    });
     // Clear the input field
    _controller.clear();
    // Call the API to get the chatbot's response
    final response = await ApiService().chatWithGPT(_controller.text);
    setState(() {
      _messages.add("Chatbot: $response");
      _isLoading = false; 
    });

   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: TColor.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length + (_isLoading ? 1 : 0), 
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(), 
                    ),
                  );
                }

                final message = _messages[index];
                bool isUserMessage = message.startsWith("You:");

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUserMessage ? TColor.primary : Color(0xFFE4E4E4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: TColor.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
