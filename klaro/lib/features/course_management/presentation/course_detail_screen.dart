// ... Keep imports and providers ...
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';
import 'package:klaro/features/course_management/logic/course_grade_provider.dart';
import 'package:klaro/features/course_management/presentation/widgets/add_component_modal.dart';
import 'package:klaro/features/course_management/presentation/widgets/add_assessment_modal.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Providers for components and assessments
final courseComponentsProvider = StreamProvider.family<List<GradingComponent>, int>((ref, courseId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.gradingComponents)..where((c) => c.courseId.equals(courseId))).watch();
});

final assessmentsProvider = StreamProvider.family<List<Assessment>, int>((ref, componentId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.assessments)..where((a) => a.componentId.equals(componentId))).watch();
});

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Components
    final componentsAsync = ref.watch(courseComponentsProvider(course.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(course.code),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 2. Show the Header
            _CourseHeader(course: course),
            
            const SizedBox(height: 24),
            
            // 3. The List
            componentsAsync.when(
              data: (components) => Column(
                children: components.map((comp) => _GradingComponentTile(component: comp)).toList(),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // OPEN MODAL: Add Component
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (ctx) => AddComponentModal(courseId: course.id),
          );
        },
        label: const Text("Add Component"),
        icon: Icon(PhosphorIcons.plus()),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _CourseHeader extends ConsumerWidget {
  final Course course;
  // We don't strictly need the components list passed here anymore
  // because the Provider handles the fetching.
  const _CourseHeader({required this.course}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH THE CALCULATED GRADE
    final gradeAsync = ref.watch(courseStandingProvider(course.id));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: "Target", value: "${course.targetGwa}"),
              
              // THE LIVE DATA
              gradeAsync.when(
                data: (standing) => _StatItem(
                  label: "Current Grade", 
                  value: "${standing.finalGrade} (${standing.percentage.toStringAsFixed(1)}%)", 
                  colorOverride: Color(GradingSystem.getGradeColor(standing.finalGrade)),
                ),
                loading: () => const _StatItem(label: "Current", value: "..."),
                error: (_,__) => const _StatItem(label: "Current", value: "Err"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Updated _StatItem to accept Color
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? colorOverride;
  
  const _StatItem({required this.label, required this.value, this.colorOverride});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align right for cleaner look
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          color: colorOverride ?? Colors.black
        )),
      ],
    );
  }
}
// --- UPDATED TILE: Opens Assessment Modal ---
class _GradingComponentTile extends ConsumerWidget {
  final GradingComponent component;
  const _GradingComponentTile({required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(assessmentsProvider(component.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(component.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          // Calculate the % for this specific bucket
          subtitle: assessmentsAsync.when(
            data: (assessments) {
              // MATH LOGIC HERE
              final score = GradeCalculator.calculateComponentScore(assessments);
              return Text("${score.toStringAsFixed(1)}% / 100% (Weight: ${(component.weightPercent * 100).toInt()}%)");
            },
            loading: () => const Text("Loading..."),
            error: (_,__) => const Text("Error"),
          ),
          children: [
            assessmentsAsync.when(
              data: (assessments) => Column(
                children: [
                  ...assessments.map((a) => ListTile(
                    title: Text(a.name),
                    subtitle: a.isExcused ? const Text("Excused", style: TextStyle(color: Colors.orange)) : null,
                    trailing: Text("${a.scoreObtained} / ${a.totalItems}"),
                    onTap: () {
                      // OPEN MODAL: Edit Assessment
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (ctx) => AddAssessmentModal(componentId: component.id, assessment: a),
                      );
                    },
                  )),
                  ListTile(
                    leading: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                    title: Text("Add Score", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // OPEN MODAL: Add Assessment
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (ctx) => AddAssessmentModal(componentId: component.id),
                      );
                    },
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_,__) => const SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}