import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiSyllabusService {
  GenerativeModel? _model;
  String? _initError;

  AiSyllabusService() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        _initError = 'GEMINI_API_KEY not found in .env file';
        return;
      }
      
      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite', // Correct model name
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1, // Low temperature for consistent extraction
          maxOutputTokens: 1024,
        ),
      );
    } catch (e) {
      _initError = 'Failed to initialize AI service: $e';
    }
  }

  /// Takes raw text from a syllabus and returns a List of Categories
  Future<List<Map<String, dynamic>>> parseSyllabusText(String text) async {
    // Check for initialization errors
    if (_initError != null) {
      throw Exception(_initError);
    }
    
    if (_model == null) {
      throw Exception('AI service not initialized');
    }
    
    final prompt = Content.text('''
You are a data extraction assistant for a university student app.
Analyze the following syllabus text.
Identify the "Grading System" or "Grade Breakdown".

Return a STRICT JSON array where each object has:
- "name": String (e.g., "Long Exams", "Quizzes", "Final Project")
- "weight": Number (The percentage as a decimal, e.g., 0.20 for 20%. If it is 20%, write 0.20)

Rules:
1. Ignore the grading scale (1.0 - 5.0). Only get the components that add up to 100%.
2. If you cannot find any grading components, return an empty JSON array [].
3. Return ONLY valid JSON, no markdown formatting.

Text to analyze:
$text
    ''');

    try {
      final response = await _model!.generateContent([prompt]);
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }

      // Clean up markdown formatting if present
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      // Validate it's actually JSON
      if (!cleanJson.startsWith('[')) {
        throw Exception('AI did not return valid JSON array');
      }
      
      final List<dynamic> decoded = jsonDecode(cleanJson);
      
      // Validate and cast to strict map
      final results = <Map<String, dynamic>>[];
      for (var e in decoded) {
        if (e is! Map) continue;
        
        try {
          results.add({
            "name": e['name'].toString(),
            "weight": double.parse(e['weight'].toString()),
          });
        } catch (e) {
          print('Skipping invalid component: $e');
        }
      }
      
      return results;

    } catch (e) {
      print("AI Parsing Error: $e");
      rethrow; // Rethrow to let UI handle the error
    }
  }
}