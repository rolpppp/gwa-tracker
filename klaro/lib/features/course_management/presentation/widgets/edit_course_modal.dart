import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';


class EditCourseModal extends ConsumerStatefulWidget {
  final Course course;
  
  const EditCourseModal({super.key, required this.course});

  @override
  ConsumerState<EditCourseModal> createState() => _EditCourseModalState();
}

class _EditCourseModalState extends ConsumerState<EditCourseModal> {
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _unitsCtrl;
  late TextEditingController _targetGwaCtrl;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.course.code);
    _nameCtrl = TextEditingController(text: widget.course.name);
    _unitsCtrl = TextEditingController(text: widget.course.units.toString());
    _targetGwaCtrl = TextEditingController(text: widget.course.targetGwa.toString());
  }

  void _save() {
    if (_codeCtrl.text.isNotEmpty && _nameCtrl.text.isNotEmpty && _unitsCtrl.text.isNotEmpty) {
      final db = ref.read(databaseProvider);
      
      db.update(db.courses).replace(
        Course(
          id: widget.course.id,
          code: _codeCtrl.text,
          name: _nameCtrl.text,
          units: double.tryParse(_unitsCtrl.text) ?? 3.0,
          targetGwa: double.tryParse(_targetGwaCtrl.text) ?? 1.0,
          colorHex: widget.course.colorHex,
          termId: widget.course.termId,
        ),
      );
      
      Navigator.pop(context, true); // Return true to indicate success
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
            "Edit Course",
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
                    labelText: "Target Grade",
                    hintText: "1.0",
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: const Text("Save"),
                ),
              ),
            ],
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
