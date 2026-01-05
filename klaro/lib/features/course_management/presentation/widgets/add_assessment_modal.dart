import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/theme/app_theme.dart';

class AddAssessmentModal extends ConsumerStatefulWidget {
  final int componentId;
  final Assessment? assessment; // Optional: if provided, we're editing
  const AddAssessmentModal({super.key, required this.componentId, this.assessment});

  @override
  ConsumerState<AddAssessmentModal> createState() => _AddAssessmentModalState();
}

class _AddAssessmentModalState extends ConsumerState<AddAssessmentModal> {
  final _nameCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  bool _isGoal = false; 
  
  bool _isExcused = false;

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill the fields
    if (widget.assessment != null) {
      _nameCtrl.text = widget.assessment!.name;
      _scoreCtrl.text = widget.assessment!.scoreObtained.toString();
      _totalCtrl.text = widget.assessment!.totalItems.toString();
      _isExcused = widget.assessment!.isExcused;
      _isGoal = widget.assessment!.isGoal;
    }
  }

  void _save() {
    if (_nameCtrl.text.isNotEmpty && _scoreCtrl.text.isNotEmpty) {
      final db = ref.read(databaseProvider);
      
      if (widget.assessment != null) {
        // UPDATE existing assessment
        db.update(db.assessments).replace(
          AssessmentsCompanion(
            id: Value(widget.assessment!.id),
            name: Value(_nameCtrl.text),
            scoreObtained: Value(double.parse(_scoreCtrl.text)),
            totalItems: Value(double.parse(_totalCtrl.text)),
            componentId: Value(widget.componentId),
            isExcused: Value(_isExcused),
            isGoal: Value(_isGoal),
          ),
        );
      } else {
        // INSERT new assessment
        db.into(db.assessments).insert(
          AssessmentsCompanion.insert(
            name: _nameCtrl.text,
            scoreObtained: double.parse(_scoreCtrl.text),
            totalItems: double.parse(_totalCtrl.text),
            componentId: widget.componentId,
            isExcused: Value(_isExcused),
            isGoal: Value(_isGoal),
          ),
        );
      }
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
            widget.assessment != null ? "Edit Score" : "Record New Score", 
            style: Theme.of(context).textTheme.titleLarge
          ),
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: "Activity Name", hintText: "Quiz #1"),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _scoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "My Score", hintText: "15"),
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("/", style: TextStyle(fontSize: 24, color: Colors.grey))),
              Expanded(
                child: TextFormField(
                  controller: _totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Total", hintText: "20"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // The Excused Toggle
          SwitchListTile(
            title: const Text("Excused / Exempted"),
            subtitle: const Text("Don't count this in the computation"),
            value: _isExcused,
            onChanged: (val) => setState(() => _isExcused = val),
            contentPadding: EdgeInsets.zero,
          ),

          SwitchListTile(
            title: const Text("Is this a Goal?"),
            subtitle: const Text("Mark as a target/hypothetical score"),
            activeColor: Colors.purpleAccent,
            value: _isGoal,
            onChanged: (val) => setState(() => _isGoal = val),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor, foregroundColor: Colors.white),
              child: Text(widget.assessment != null ? "Update Score" : "Save Score"),
            ),
          ),
        ],
      ),
    );
  }
}