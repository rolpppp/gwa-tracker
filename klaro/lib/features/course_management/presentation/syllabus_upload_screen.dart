import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/ai_syllabus_parser.dart';
import 'package:klaro/core/services/database.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class SyllabusUploadScreen extends ConsumerStatefulWidget {
  final int courseId;
  const SyllabusUploadScreen({super.key, required this.courseId});

  @override
  ConsumerState<SyllabusUploadScreen> createState() =>
      _SyllabusUploadScreenState();
}

class _SyllabusUploadScreenState extends ConsumerState<SyllabusUploadScreen> {
  AiSyllabusService? _aiService;
  bool _isLoading = false;
  List<Map<String, dynamic>>? _detectedComponents;
  String _statusMessage = "Upload PDF to extract grading components";

  @override
  void initState() {
    super.initState();
    // Initialize AI service and check for errors
    try {
      _aiService = AiSyllabusService();
    } catch (e) {
      setState(() {
        _statusMessage = "AI service unavailable: $e";
      });
    }
  }

  Future<void> _pickAndParse() async {
    if (_aiService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'AI service is not available. Check your API key configuration.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Selecting file...";
    });

    try {
      // 1. Pick File
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
        ], // For MVP, let's stick to PDF text extraction
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
        final components = await _aiService!.parseSyllabusText(text);

        if (components.isEmpty) {
          setState(() {
            _statusMessage = "No grading components found";
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not find grading components in the PDF. Try manual entry.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          setState(() {
            _detectedComponents = components;
            _statusMessage = "Found ${components.length} components!";
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      final errorMessage = e.toString();
      setState(() {
        _isLoading = false;
        _statusMessage = "Error occurred";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.contains('GEMINI_API_KEY')
                  ? 'AI service not configured. Create manual components instead.'
                  : 'Error: ${errorMessage.length > 100 ? errorMessage.substring(0, 100) : errorMessage}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _saveComponents() {
    if (_detectedComponents == null) return;

    final db = ref.read(databaseProvider);

    // Batch Insert
    for (var comp in _detectedComponents!) {
      db
          .into(db.gradingComponents)
          .insert(
            GradingComponentsCompanion.insert(
              name: comp['name'],
              weightPercent: comp['weight'],
              courseId: widget.courseId,
            ),
          );
    }

    Navigator.pop(context); // Close screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Syllabus Applied!")));
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
              onTap: _isLoading || _aiService == null ? null : _pickAndParse,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _aiService == null
                      ? Theme.of(context).colorScheme.errorContainer
                      : (_isLoading
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _aiService == null
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.outline,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_aiService == null)
                      Icon(
                        PhosphorIcons.warning(),
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      )
                    else
                      Icon(
                        PhosphorIcons.cloudArrowUp(),
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _aiService == null
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // RESULTS AREA
            if (_detectedComponents != null) ...[
              const Text(
                "Detected Components:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                        leading: Icon(
                          PhosphorIcons.checkCircle(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
              ),
            ] else if (!_isLoading && _statusMessage.contains("Error")) ...[
              Text(
                "Try uploading a clearer PDF or enter manually.",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
