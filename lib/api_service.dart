import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "http://192.168.231.154:5000/api/v1/chat/completions";  
  final String baseUrl = 'http://10.0.2.2:8000';

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
  Future<List<dynamic>> filterJobs({
    String? jobTitle,
    String? skills,
    String? company,
    String? location,
    String? experienceLevel,
    String? salaryRange,
    String? datePosted,
  }) async {
    final uri = Uri.parse('$baseUrl/filter-jobs').replace(queryParameters: {
      if (jobTitle != null && jobTitle.isNotEmpty) 'job_title': jobTitle,
      if (skills != null && skills.isNotEmpty) 'skills': skills,
      if (company != null && company.isNotEmpty) 'company': company,
      if (location != null && location.isNotEmpty) 'location': location,
      if (experienceLevel != null && experienceLevel.isNotEmpty) 'experience_level': experienceLevel,
      if (salaryRange != null && salaryRange.isNotEmpty) 'salary_range': salaryRange,
      if (datePosted != null && datePosted.isNotEmpty) 'date_posted': datePosted,
    });

    final response = await http.get(uri);
    print(response.body); // Debug: Check response from server

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Ensure that the key 'filtered_jobs' exists and contains a list
      if (data != null && data['filtered_jobs'] is List) {
        return data['filtered_jobs'] ?? [];
      } else {
        throw Exception('Failed to load jobs: filtered_jobs not found');
      }
    } else {
      throw Exception('Failed to load jobs, status code: ${response.statusCode}');
    }
  }

}
