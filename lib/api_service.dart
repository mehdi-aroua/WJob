import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "http://192.168.1.12:5000/api/v1/chat/completions";  // Local server URL

  Future<String> chatWithGPT(String userMessage) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'messages': [
          {'role': 'system', 'content': 'You are a helpful chatbot.'},
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to load response');
    }
  }
}
