import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/ai_syllabus_parser.dart';
import 'package:klaro/core/services/database.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class SyllabusUploadScreen extends ConsumerStatefulWidget {
  final int courseId;
  const SyllabusUploadScreen({super.key, required this.courseId});

  @override
  ConsumerState<SyllabusUploadScreen> createState() => _SyllabusUploadScreenState();
}

class _SyllabusUploadScreenState extends ConsumerState<SyllabusUploadScreen> {
  final _aiService = AiSyllabusService();
  bool _isLoading = false;
  List<Map<String, dynamic>>? _detectedComponents;
  String _statusMessage = "Upload PDF or Text Image";

  Future<void> _pickAndParse() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Selecting file...";
    });

    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // For MVP, let's stick to PDF text extraction
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        
        setState(() => _statusMessage = "Reading file...");
        
        // 2. Extract Text (Basic PDF extraction)
        // Note: For Images, we would send the bytes directly to Gemini.
        // For PDFs, extracting text is cheaper/faster if it's text-based.
        String text = await ReadPdfText.getPDFtext(file.path);
        
        if (text.isEmpty) {
           throw Exception("Could not read text. Is this a scanned image?");
        }

        setState(() => _statusMessage = "AI Analyzing...");

        // 3. Send to AI
        final components = await _aiService.parseSyllabusText(text);
        
        setState(() {
          _detectedComponents = components;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _saveComponents() {
    if (_detectedComponents == null) return;
    
    final db = ref.read(databaseProvider);
    
    // Batch Insert
    for (var comp in _detectedComponents!) {
      db.into(db.gradingComponents).insert(
        GradingComponentsCompanion.insert(
          name: comp['name'],
          weightPercent: comp['weight'],
          courseId: widget.courseId,
        )
      );
    }
    
    Navigator.pop(context); // Close screen
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Syllabus Applied!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Syllabus Parser")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // UPLOAD AREA
            GestureDetector(
              onTap: _isLoading ? null : _pickAndParse,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(_statusMessage, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // RESULTS AREA
            if (_detectedComponents != null) ...[
              const Text("Detected Components:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _detectedComponents!.length,
                  itemBuilder: (context, index) {
                    final item = _detectedComponents![index];
                    return Card(
                      child: ListTile(
                        title: Text(item['name']),
                        trailing: Text("${(item['weight'] * 100).toInt()}%"),
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveComponents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Confirm & Import"),
                ),
              )
            ] else if (!_isLoading && _statusMessage.contains("Error")) ... [
               const Text("Try uploading a clearer PDF or enter manually.", style: TextStyle(color: Colors.red))
            ]
          ],
        ),
      ),
    );
  }
}