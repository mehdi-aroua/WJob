import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String apiUrl = "http://192.168.231.154:5000/api/v1/chat/completions";  
  final String baseUrl = 'http://192.168.1.81:8000';

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

  Future<Map<String, dynamic>> signupUser({
    required String nom,
    required String prenom,
    required String ville,
    required String phone,
    required String email,
    required String password,
    required String dateAnniversaire,
    String photoBase64 = '',
  }) async {
    final url = Uri.parse('$baseUrl/signup');
    
    final Map<String, dynamic> requestBody = {
      'nom': nom,
      'prenom': prenom,
      'ville': ville,
      'phone': phone,
      'email': email,
      'password': password,
      'date_anniverssaire': dateAnniversaire,
      'photo': photoBase64,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      print('signup: ${response.statusCode}');
      print('signup: ${response.body}');

      if (response.statusCode == 200) {
        // Sauvegarder les données dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token'] ?? '');
        await prefs.setString('userId', responseData['user']['_id'] ?? '');
        await prefs.setString('nom', responseData['user']['nom'] ?? nom);
        await prefs.setString('prenom', responseData['user']['prenom'] ?? prenom);
        await prefs.setString('email', responseData['user']['email'] ?? email);
        await prefs.setString('phone', responseData['user']['phone'] ?? phone);
        await prefs.setString('ville', responseData['user']['ville'] ?? ville);
        await prefs.setString('dateAnniversaire', responseData['user']['date_anniverssaire'] ?? dateAnniversaire);
        if (photoBase64.isNotEmpty) {
          await prefs.setString('photo', photoBase64);
        }
        
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print('login: ${response.statusCode}');
      print('login: ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  Future<Map<String, dynamic>> extractCv(File cvFile) async {
  try {
    print('[DEBUG] Début de extractCv');
    print('[DEBUG] Fichier à envoyer : ${cvFile.path}');
    print('[DEBUG] Taille du fichier : ${await cvFile.length()} octets');

    var uri = Uri.parse('$baseUrl/extract-cv');
    print('[DEBUG] URI de l\'API : $uri');

    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        cvFile.path,
        filename: cvFile.path.split('/').last,
      ),
    );

    print('[DEBUG] Requête préparée avec succès. Envoi en cours...');

    var streamedResponse = await request.send();
    print('[DEBUG] Réponse reçue. Lecture du flux...');

    var response = await http.Response.fromStream(streamedResponse);
    print('[DEBUG] Status Code : ${response.statusCode}');
    print('[DEBUG] Body de la réponse : ${response.body}');

    if (response.statusCode == 200) {
      print('[DEBUG] Succès de l\'extraction');
      return json.decode(response.body);
    } else {
      print('[ERROR] Échec de l\'extraction');
      throw Exception('Échec de l\'extraction du CV: ${response.statusCode} - ${response.body}');
    }
  } catch (e, stackTrace) {
    print('[EXCEPTION] Une erreur est survenue dans extractCv');
    print('Erreur: $e');
    print('StackTrace: $stackTrace');
    throw Exception('Erreur lors de l\'envoi du CV: $e');
  }
}


  Future<Map<String, dynamic>> extractCvFromBytes(Uint8List pdfBytes) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/extract-cv'),
    );
    
    // Create a multipart file from bytes instead of a file path
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        pdfBytes,
        filename: 'cv.pdf',
        contentType: MediaType('application', 'pdf'),
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to extract CV: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Error sending CV: $e');
  }
}
  Future<Map<String, dynamic>> matchJobs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/match-jobs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        throw Exception('Aucun CV extrait. Veuillez d\'abord extraire un CV.');
      } else {
        throw Exception('Échec de la correspondance des jobs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche de jobs correspondants: $e');
    }
  }
  Future<Map<String, dynamic>> scrapeLinkedInProfile(String profileUrl) async {
    try {
      final uri = Uri.parse('$baseUrl/scrape-linkedin-profile')
        .replace(queryParameters: {
          'profile_url': profileUrl,
        });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      print('[DEBUG] Status Code: ${response.statusCode}');
      print('[DEBUG] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to scrape LinkedIn profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] Error scraping LinkedIn profile: $e');
      throw Exception('Error scraping LinkedIn profile: $e');
    }
  }
  Future<List<Map<String, dynamic>>> matchJobsLinkedIn() async {
    try {
      final uri = Uri.parse('$baseUrl/match-jobs-Linkdin');

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      print('[DEBUG] Status Code: ${response.statusCode}');
      print('[DEBUG] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['best_jobs']);
      } else {
        throw Exception('Failed to match jobs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[EXCEPTION] Error matching jobs: $e');
      throw Exception('Error matching jobs: $e');
    }
  }

}
