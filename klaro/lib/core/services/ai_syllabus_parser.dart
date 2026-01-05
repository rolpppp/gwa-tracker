import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiSyllabusService {
  late final GenerativeModel _model;

  AiSyllabusService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Fast and stable model
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Force JSON response
      ),
    );
  }

  /// Takes raw text from a syllabus and returns a List of Categories
  Future<List<Map<String, dynamic>>> parseSyllabusText(String text) async {
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
      3. Do not include markdown formatting like ```json. Just the raw JSON.
      
      Text to analyze:
      $text
    ''');

    try {
      final response = await _model.generateContent([prompt]);
      final responseText = response.text;
      
      if (responseText == null) return [];

      // Clean up if the AI adds backticks despite instructions
      final cleanJson = responseText.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> decoded = jsonDecode(cleanJson);
      
      // Cast to strict map
      return decoded.map((e) => {
        "name": e['name'].toString(),
        "weight": double.parse(e['weight'].toString()),
      }).toList();

    } catch (e) {
      print("AI Parsing Error: $e");
      return [];
    }
  }
}