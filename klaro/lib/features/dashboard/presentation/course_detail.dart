import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 1. Create a Provider Family to fetch components specific to THIS course
final courseComponentsProvider = StreamProvider.family<List<GradingComponent>, int>((ref, courseId) {
  return ref.watch(databaseProvider).watchComponents(courseId);
});

// 2. Create a Provider Family to fetch assessments for a component
final assessmentsProvider = StreamProvider.family<List<Assessment>, int>((ref, componentId) {
  return ref.watch(databaseProvider).watchAssessments(componentId);
});

class CourseDetailScreen extends ConsumerWidget {
  final Course course; // We pass the Course object from Dashboard

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final componentsAsync = ref.watch(courseComponentsProvider(course.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(course.code, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(PhosphorIcons.dotsThreeVertical()), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CARD
            _buildHeaderCard(context),
            const SizedBox(height: 24),

            // TABS (Simple Toggle for now)
            Row(
              children: [
                _buildTab("Grades", true),
                const SizedBox(width: 12),
                _buildTab("Syllabus", false),
              ],
            ),
            const SizedBox(height: 24),

            // DYNAMIC COMPONENT LIST
            componentsAsync.when(
              data: (components) {
                if (components.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return Column(
                  children: components.map((comp) => _GradingComponentTile(component: comp)).toList(),
                );
              },
              error: (err, _) => Text("Error: $err"),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddComponentModal(context, ref),
        label: const Text("Add Component"),
        icon: Icon(PhosphorIcons.plus()),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat("Target", "${course.targetGwa}"),
              _buildStat("Current", "1.0", isColor: true), // Hardcoded for now, we will wire logic later
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool isColor = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        Text(value, style: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold, 
          color: isColor ? const Color(0xFF4ADE80) : Colors.black
        )),
      ],
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1F36) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(
        color: isSelected ? Colors.white : Colors.grey, 
        fontWeight: FontWeight.w600
      )),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(PhosphorIcons.bookOpen(), size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No grading components yet."),
          TextButton(
            onPressed: () {
               // Manual Add for MVP
               _showAddComponentModal(context, ref);
            },
            child: const Text("Create Manually or Upload Syllabus"),
          )
        ],
      ),
    );
  }

  void _showAddComponentModal(BuildContext context, WidgetRef ref) {
    // We will implement this input form next
    // It creates a "GradingComponent" row in the DB
    final db = ref.read(databaseProvider);
    db.into(db.gradingComponents).insert(
      GradingComponentsCompanion.insert(
        name: "Quizzes", 
        weightPercent: 0.20, // 20%
        courseId: course.id,
      )
    );
  }
}

// --- SUB-WIDGET: The Accordion Tile ---
class _GradingComponentTile extends ConsumerWidget {
  final GradingComponent component;
  const _GradingComponentTile({required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(assessmentsProvider(component.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(component.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${(component.weightPercent * 100).toInt()}% of Grade"),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)),
            child: Icon(PhosphorIcons.target(), color: Colors.orange[700], size: 20),
          ),
          children: [
            assessmentsAsync.when(
              data: (assessments) => Column(
                children: [
                  ...assessments.map((a) => ListTile(
                    title: Text(a.name),
                    trailing: Text("${a.scoreObtained} / ${a.totalItems}"),
                  )),
                  // "Add Grade" Button
                  ListTile(
                    leading: const Icon(Icons.add, size: 18),
                    title: const Text("Add Score", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    onTap: () {
                       final db = ref.read(databaseProvider);
                       db.into(db.assessments).insert(
                         AssessmentsCompanion.insert(
                           name: "New Activity", 
                           scoreObtained: 10, 
                           totalItems: 10, 
                           componentId: component.id
                         )
                       );
                    },
                  ),
                ],
              ),
              loading: () => const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
              error: (_,__) => const SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}