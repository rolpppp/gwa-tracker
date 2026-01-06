import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';


class AddComponentModal extends ConsumerStatefulWidget {
  final int courseId;
  final GradingComponent? component; // Optional: for editing
  
  const AddComponentModal({
    super.key, 
    required this.courseId,
    this.component,
  });

  @override
  ConsumerState<AddComponentModal> createState() => _AddComponentModalState();
}

class _AddComponentModalState extends ConsumerState<AddComponentModal> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.component != null) {
      _nameCtrl.text = widget.component!.name;
      _weightCtrl.text = (widget.component!.weightPercent * 100).toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text;
      // User inputs "20" for 20%, we store 0.20
      final weight = double.parse(_weightCtrl.text) / 100;

      final db = ref.read(databaseProvider);
      
      if (widget.component != null) {
        // Update existing component
        db.update(db.gradingComponents).replace(
          GradingComponent(
            id: widget.component!.id,
            name: name,
            weightPercent: weight,
            courseId: widget.courseId,
          ),
        );
      } else {
        // Insert new component
        db.into(db.gradingComponents).insert(
          GradingComponentsCompanion.insert(
            name: name,
            weightPercent: weight,
            courseId: widget.courseId,
          ),
        );
      }

      Navigator.pop(context); // Close modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Handle keyboard covering screen
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.component != null ? "Edit Grading Category" : "New Grading Category",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Name Input
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Category Name",
                hintText: "e.g., Quizzes, Attendance",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            
            // Weight Input
            TextFormField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (%)",
                hintText: "e.g., 20",
                suffixText: "%",
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Required";
                final n = double.tryParse(v);
                if (n == null || n <= 0 || n > 100) return "Invalid %";
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(widget.component != null ? "Update Category" : "Create Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}