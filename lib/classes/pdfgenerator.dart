import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' show SnackBar, ScaffoldMessenger, debugPrint;

class PdfGenerator {
  static List<Map<String, dynamic>> bigList = []; 
  static List<Map<String, dynamic>> BigList = []; // Add BigList to store all form data

  static void clearBigList() {
    bigList.clear();
  }
  
  static pw.Document _mainPdfDocument = pw.Document();
  static bool _isInitialized = false;
  static final String _fixedFileName = 'cvForm.pdf';
  static Uint8List? _pdfBytes;
  
  static Future<void> _initializeDocument() async {
    if (!_isInitialized) {
      // Create a new document when first initialized
      _mainPdfDocument = pw.Document();
      _isInitialized = true;
    }
  }

  static Future<PdfResult> generateCV(List<Map<String, dynamic>> data) async {
    try {
      debugPrint('Starting CV generation...');
      
      final pdf = pw.Document();
      
      // Create PDF with built-in fonts
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => _buildContent(data),
        ),
      );

      // Save PDF to memory only - no file system access
      final bytes = await pdf.save();
      _pdfBytes = bytes; // Store the bytes for later use
      
      debugPrint('PDF generated in memory, size: ${bytes.length} bytes');
      
      return PdfResult(
        success: true,
        bytes: bytes,
        filePath: 'in-memory-cv.pdf',
        errorMessage: null,
      );
    } catch (e) {
      debugPrint('Error in generateCV: $e');
      
      // Create a very basic fallback PDF
      try {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (context) => pw.Center(
              child: pw.Text('Basic CV - Error occurred during generation: $e'),
            ),
          ),
        );
        
        final bytes = await pdf.save();
        _pdfBytes = bytes;
        
        return PdfResult(
          success: true,
          bytes: bytes,
          filePath: 'fallback-cv.pdf',
          errorMessage: 'Generated with errors: $e',
        );
      } catch (fallbackError) {
        debugPrint('Error in fallback PDF generation: $fallbackError');
        
        return PdfResult(
          success: false, 
          bytes: null,
          filePath: null,
          errorMessage: 'Failed to generate PDF: $e. Fallback also failed: $fallbackError',
        );
      }
    }
  }

  static Uint8List? getLatestPdfBytes() {
    return _pdfBytes;
  }

  static List<pw.Widget> _buildContent(List<Map<String, dynamic>> data) {
    List<pw.Widget> widgets = [];

    // Personal Information
    final personalInfo = data.firstWhere(
      (item) => item['form_type'] == 'Personal Information',
      orElse: () => {},
    );
    if (personalInfo.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 0,
          child: pw.Text('${personalInfo['name']}',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        ),
      );
      widgets.add(
        pw.Paragraph(
          text:
              '${personalInfo['email']} | ${personalInfo['phone']} | ${personalInfo['address']}, ${personalInfo['city']}, ${personalInfo['country']}',
        ),
      );
      widgets.add(pw.Divider());
    }

    // About Me
    if (personalInfo['aboutMe'] != null) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('About Me'),
        ),
      );
      widgets.add(
        pw.Paragraph(text: personalInfo['aboutMe']),
      );
      widgets.add(pw.SizedBox(height: 10));
    }

    // Education
    final educationItems = data.where((item) => item['form_type'] == 'Education').toList();
    if (educationItems.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Education'),
        ),
      );
      for (var edu in educationItems) {
        widgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${edu['school']} - ${edu['degree']}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('${edu['startDate']} - ${edu['endDate']}'),
              pw.Text(edu['description'] ?? ''),
              pw.SizedBox(height: 8),
            ],
          ),
        );
      }
      widgets.add(pw.SizedBox(height: 10));
    }

    // Work Experience
    final experienceItems = data.where((item) => item['form_type'] == 'Work Experience').toList();
    if (experienceItems.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Work Experience'),
        ),
      );
      for (var exp in experienceItems) {
        widgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${exp['jobTitle']} at ${exp['company']}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('${exp['location']}, ${exp['country']}'),
              pw.Text('${exp['startDate']} - ${exp['endDate']}'),
              pw.Text('Responsibilities: ${exp['responsibilities']}'),
              pw.SizedBox(height: 8),
            ],
          ),
        );
      }
      widgets.add(pw.SizedBox(height: 10));
    }

    // Skills
    final skillItems = data.where((item) => item['form_type'] == 'Skill').toList();
    if (skillItems.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Skills'),
        ),
      );
      widgets.add(
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: skillItems
              .map((skill) => pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius: pw.BorderRadius.circular(16),
                    ),
                    padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: pw.Text('${skill['skill']} (${skill['level']})'),
                  ))
              .toList(),
        ),
      );
      widgets.add(pw.SizedBox(height: 10));
    }

    // Certifications
    final certItems = data.where((item) => item['form_type'] == 'Certification').toList();
    if (certItems.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Certifications'),
        ),
      );
      for (var cert in certItems) {
        widgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                cert['title'],
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('${cert['organization']} - ${cert['date']}'),
              if (cert['description'] != null) pw.Text(cert['description']),
              pw.SizedBox(height: 8),
            ],
          ),
        );
      }
      widgets.add(pw.SizedBox(height: 10));
    }

    // Languages
    final languageItems = data.where((item) => item['form_type'] == 'Language').toList();
    if (languageItems.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Languages'),
        ),
      );
      widgets.add(
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: languageItems
              .map((lang) => pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius: pw.BorderRadius.circular(16),
                    ),
                    padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: pw.Text('${lang['language']} (${lang['proficiency']})'),
                  ))
              .toList(),
        ),
      );
      widgets.add(pw.SizedBox(height: 10));
    }

    // Social Media
    final socialMedia = data.firstWhere(
      (item) => item['form_type'] == 'Social Media',
      orElse: () => {},
    );
    if (socialMedia.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Social Media'),
        ),
      );
      widgets.add(
        pw.Row(
          children: [
            if (socialMedia['LinkedIn'] != null)
              pw.Text('LinkedIn: ${socialMedia['LinkedIn']} '),
            if (socialMedia['GitHub'] != null)
              pw.Text('GitHub: ${socialMedia['GitHub']} '),
            if (socialMedia['Twitter'] != null)
              pw.Text('Twitter: ${socialMedia['Twitter']} '),
          ],
        ),
      );
    }

    // Cover Letters
    final coverLetters = data.where((item) => item['form_type'] == 'Cover Letter').toList();
    if (coverLetters.isNotEmpty) {
      widgets.add(
        pw.Header(
          level: 1,
          child: pw.Text('Cover Letters'),
        ),
      );
      for (var letter in coverLetters) {
        widgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Cover Letter (${letter['date_added']})'),
              pw.SizedBox(height: 4),
              pw.Text(letter['cover_letter']),
              pw.SizedBox(height: 16),
            ],
          ),
        );
      }
    }

    return widgets;
  }

  // Make sure each method from append* calls this first to ensure we have the current state
  static Future<void> _ensureDocumentReady() async {
    if (!_isInitialized) {
      await _initializeDocument();
    }
  }
}

// Result class to better handle PDF generation results
class PdfResult {
  final bool success;
  final Uint8List? bytes;
  final String? filePath;
  final String? errorMessage;
  
  PdfResult({
    required this.success,
    this.bytes,
    this.filePath,
    this.errorMessage,
  });
}