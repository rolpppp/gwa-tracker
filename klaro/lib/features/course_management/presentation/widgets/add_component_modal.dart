import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


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
  double _existingTotalWeight = 0.0;
  bool _isLoadingWeight = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.component != null) {
      _nameCtrl.text = widget.component!.name;
      _weightCtrl.text = (widget.component!.weightPercent * 100).toStringAsFixed(0);
    }
    _loadExistingWeight();
  }
  
  Future<void> _loadExistingWeight() async {
    final db = ref.read(databaseProvider);
    final components = await (db.select(db.gradingComponents)
      ..where((c) => c.courseId.equals(widget.courseId)))
      .get();
    
    double total = 0.0;
    for (final component in components) {
      // When editing, exclude the current component's weight
      if (widget.component == null || component.id != widget.component!.id) {
        total += component.weightPercent;
      }
    }
    
    setState(() {
      _existingTotalWeight = total;
      _isLoadingWeight = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameCtrl.text;
      // User inputs "20" for 20%, we store 0.20
      final weight = double.parse(_weightCtrl.text) / 100;
      
      // Check if total weight would exceed 100%
      final newTotal = _existingTotalWeight + weight;
      if (newTotal > 1.0) {
        final remainingWeight = (1.0 - _existingTotalWeight) * 100;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Total weight would exceed 100%. Maximum available: ${remainingWeight.toStringAsFixed(1)}%',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final db = ref.read(databaseProvider);
      
      if (widget.component != null) {
        // Update existing component
        await db.update(db.gradingComponents).replace(
          GradingComponent(
            id: widget.component!.id,
            name: name,
            weightPercent: weight,
            courseId: widget.courseId,
          ),
        );
      } else {
        // Insert new component
        await db.into(db.gradingComponents).insert(
          GradingComponentsCompanion.insert(
            name: name,
            weightPercent: weight,
            courseId: widget.courseId,
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context); // Close modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingWeight = (1.0 - _existingTotalWeight) * 100;
    
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
            const SizedBox(height: 8),
            
            // Show total weight info
            if (!_isLoadingWeight)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: remainingWeight <= 0 
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: remainingWeight <= 0 
                      ? Colors.red.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      remainingWeight <= 0 ? PhosphorIcons.warning() : PhosphorIcons.info(),
                      color: remainingWeight <= 0 ? Colors.red : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        remainingWeight <= 0
                          ? "Components already total 100%. Edit existing components to add more."
                          : "Current total: ${(_existingTotalWeight * 100).toStringAsFixed(1)}% • Available: ${remainingWeight.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          color: remainingWeight <= 0 ? Colors.red[900] : Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
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
              decoration: InputDecoration(
                labelText: "Weight (%)",
                hintText: remainingWeight > 0 
                  ? "Max: ${remainingWeight.toStringAsFixed(1)}%" 
                  : "e.g., 20",
                suffixText: "%",
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Required";
                final n = double.tryParse(v);
                if (n == null || n <= 0) return "Must be greater than 0";
                if (n > 100) return "Cannot exceed 100%";
                
                // Check if it would exceed remaining weight
                final newTotal = _existingTotalWeight + (n / 100);
                if (newTotal > 1.0) {
                  return "Max ${remainingWeight.toStringAsFixed(1)}% available";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoadingWeight ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isLoadingWeight 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.component != null ? "Update Category" : "Create Category"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
