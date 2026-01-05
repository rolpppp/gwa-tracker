import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';
import 'package:klaro/features/dashboard/logic/term_repository.dart';
import 'package:klaro/core/theme/app_theme.dart';

class AddCourseModal extends ConsumerStatefulWidget {
  const AddCourseModal({super.key});

  @override
  ConsumerState<AddCourseModal> createState() => _AddCourseModalState();
}

class _AddCourseModalState extends ConsumerState<AddCourseModal> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController();
  final _targetGwaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default target GWA
    _targetGwaCtrl.text = '1.0';
  }

  void _save() {
    if (_codeCtrl.text.isNotEmpty && _nameCtrl.text.isNotEmpty && _unitsCtrl.text.isNotEmpty) {
      final activeTerm = ref.read(activeTermProvider).value;
      
      if (activeTerm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an active term first")),
        );
        return;
      }
      
      ref.read(courseActionsProvider).addCourse(
        name: _nameCtrl.text,
        code: _codeCtrl.text,
        targetGwa: double.tryParse(_targetGwaCtrl.text) ?? 1.0,
        units: double.tryParse(_unitsCtrl.text) ?? 3.0,
        termId: activeTerm.id,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Add New Course",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _codeCtrl,
            decoration: const InputDecoration(
              labelText: "Course Code",
              hintText: "e.g., Math 54",
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "Course Name",
              hintText: "e.g., Advanced Calculus",
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _unitsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Units",
                    hintText: "3",
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _targetGwaCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Target GWA",
                    hintText: "1.0",
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Course"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _unitsCtrl.dispose();
    _targetGwaCtrl.dispose();
    super.dispose();
  }
}
