import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grade_display_helper.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/course_management/logic/grade_calculator.dart';
import 'package:klaro/features/course_management/logic/course_grade_provider.dart';
import 'package:klaro/features/course_management/presentation/widgets/add_component_modal.dart';
import 'package:klaro/features/course_management/presentation/widgets/add_assessment_modal.dart';
import 'package:klaro/features/course_management/presentation/widgets/edit_course_modal.dart';
import 'package:klaro/features/course_management/presentation/widgets/component_simulator_modal.dart';
import 'package:klaro/features/course_management/presentation/syllabus_upload_screen.dart';
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
        actions: [
          PopupMenuButton<String>(
            icon: Icon(PhosphorIcons.dotsThreeVertical()),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.pencil(), size: 18),
                    const SizedBox(width: 8),
                    const Text("Edit Course"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.trash(), size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text("Delete Course", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) => EditCourseModal(course: course),
                );
                // If edit was successful, we might want to refresh
                if (result == true && context.mounted) {
                  // The providers will auto-refresh via StreamProvider
                }
              } else if (value == 'delete') {
                _showDeleteConfirmation(context, ref);
              }
            },
          ),
        ],
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
              data: (components) {
                if (components.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return Column(
                  children: components.map((comp) => _GradingComponentTile(component: comp)).toList(),
                );
              },
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Course?"),
        content: Text(
          "This will permanently delete '${course.code}' and ALL grading components and assessments. This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(db.courses)..where((c) => c.id.equals(course.id))).go();
              if (context.mounted) {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to dashboard
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
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
          const SizedBox(height: 16),
          
          // AI UPLOAD BUTTON
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => SyllabusUploadScreen(courseId: course.id))
              );
            },
            icon: const Icon(Icons.auto_awesome), // Sparkles icon
            label: const Text("Import via AI Syllabus"),
          ),
          
          TextButton(
            onPressed: () => _showAddComponentModal(context, ref), // The manual way
            child: const Text("Create Manually"),
          )
        ],
      ),
    );
  }

  void _showAddComponentModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => AddComponentModal(courseId: course.id),
    );
  }
}

class _CourseHeader extends ConsumerWidget {
  final Course course;
  const _CourseHeader({required this.course}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH THE CALCULATED GRADE
    final gradeAsync = ref.watch(courseStandingProvider(course.id));
    
    // WATCH COMPONENTS to calculate total weight used
    final componentsAsync = ref.watch(courseComponentsProvider(course.id));
    
    // Get selected grading system
    final selectedSystem = ref.watch(preferencesProvider).selectedGradingSystem;

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
              
              // THE LIVE DATA - Shows Real vs Projected
              gradeAsync.when(
                data: (standing) {
                  // If not enough data, show incomplete status
                  if (!standing.hasEnoughData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Current Grade",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "--",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                "${(standing.weightGraded * 100).toStringAsFixed(0)}% graded",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  
                  // Check if we have goals active (Real != Projected)
                  bool hasGoals = standing.realPercentage != standing.projectedPercentage;
                  
                  // Convert grades to selected system
                  final projectedGrade = GradeDisplayHelper.formatGrade(standing.projectedPercentage, selectedSystem);
                  final realGrade = GradeDisplayHelper.formatGrade(standing.realPercentage, selectedSystem);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasGoals ? "Projected Grade" : "Current Grade", 
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          if (hasGoals) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.flag_circle, color: Colors.purpleAccent, size: 14),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // If we have goals, show "Projected" big and "Real" small
                      if (hasGoals) ...[
                        GestureDetector(
                          onTap: () {
                            // Show percentage tooltip
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Grade Breakdown"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Projected: ${standing.projectedPercentage.toStringAsFixed(1)}% ($projectedGrade)",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Real: ${standing.realPercentage.toStringAsFixed(1)}% ($realGrade)",
                                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purpleAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      projectedGrade,
                                      style: const TextStyle(
                                        fontSize: 28, 
                                        fontWeight: FontWeight.bold, 
                                        color: Colors.purpleAccent,
                                      ),
                                    ),
                                    Text(
                                      "Real: $realGrade",
                                      style: TextStyle(
                                        fontSize: 11, 
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.info_outline, size: 16, color: Colors.purpleAccent.withOpacity(0.6)),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard View with info icon
                        GestureDetector(
                          onTap: () {
                            // Show percentage tooltip
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Grade Details"),
                                content: Text(
                                  "Percentage: ${standing.realPercentage.toStringAsFixed(1)}%\nGrade: $realGrade",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                realGrade,
                                style: TextStyle(
                                  fontSize: 28, 
                                  fontWeight: FontWeight.bold, 
                                  color: Color(GradeDisplayHelper.getGradeColorForSystem(standing.realPercentage, selectedSystem)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.info_outline, 
                                size: 16, 
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const _StatItem(label: "Current", value: "..."),
                error: (_,__) => const _StatItem(label: "Current", value: "Err"),
              ),
            ],
          ),
          
          // Grading Progress Indicator
          gradeAsync.when(
            data: (standing) {
              if (standing.weightGraded > 0 && standing.weightGraded < 1.0) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: standing.hasEnoughData ? Colors.blue[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: standing.hasEnoughData ? Colors.blue[200]! : Colors.orange[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            standing.hasEnoughData ? Icons.info_outline : Icons.warning_amber_rounded,
                            size: 18,
                            color: standing.hasEnoughData ? Colors.blue[700] : Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              standing.hasEnoughData
                                  ? "${(standing.weightGraded * 100).toStringAsFixed(0)}% of course graded"
                                  : "Only ${(standing.weightGraded * 100).toStringAsFixed(0)}% graded - add more assessments for accurate grade",
                              style: TextStyle(
                                fontSize: 12,
                                color: standing.hasEnoughData ? Colors.blue[800] : Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          
          // Goal Simulator Button
          componentsAsync.when(
            data: (components) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.blue.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Get current standing value
                      final standingValue = gradeAsync.value;
                      if (standingValue != null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (ctx) => ComponentSimulatorModal(
                            courseId: course.id,
                            currentGrade: standingValue.realGrade,
                            currentPercentage: standingValue.realPercentage,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up, color: Colors.purple.shade700),
                          const SizedBox(width: 8),
                          Text(
                            "Grade Simulator",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Simple stat display widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          color: Colors.black,
        )),
      ],
    );
  }
}
// --- UPDATED TILE: Opens Assessment Modal ---
class _GradingComponentTile extends ConsumerWidget {
  final GradingComponent component;
  const _GradingComponentTile({required this.component});

  Future<void> _deleteComponent(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Component"),
        content: Text("Delete '${component.name}' and all its assessments?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      // Delete all assessments first
      await (db.delete(db.assessments)
        ..where((a) => a.componentId.equals(component.id))).go();
      // Then delete the component
      await (db.delete(db.gradingComponents)
        ..where((c) => c.id.equals(component.id))).go();
    }
  }

  Future<void> _deleteAssessment(BuildContext context, WidgetRef ref, Assessment assessment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Assessment"),
        content: Text("Delete '${assessment.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await (db.delete(db.assessments)
        ..where((a) => a.id.equals(assessment.id))).go();
    }
  }

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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show expand/collapse icon
              const Icon(Icons.expand_more),
              const SizedBox(width: 8),
              // Three-dot menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Edit Component'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete Component', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (ctx) => AddComponentModal(
                        courseId: component.courseId,
                        component: component,
                      ),
                    );
                  } else if (value == 'delete') {
                    _deleteComponent(context, ref);
                  }
                },
              ),
            ],
          ),
          // Calculate the % for this specific bucket
          subtitle: assessmentsAsync.when(
            data: (assessments) {
              // Separate real and all assessments
              final realAssessments = assessments.where((a) => !a.isGoal).toList();
              final hasGoals = assessments.any((a) => a.isGoal);
              
              final realScore = GradeCalculator.calculateComponentScore(realAssessments);
              final projectedScore = GradeCalculator.calculateComponentScore(assessments);
              
              if (hasGoals) {
                return RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: "${projectedScore.toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " (Real: ${realScore.toStringAsFixed(1)}%) ",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      TextSpan(
                        text: "• Weight: ${(component.weightPercent * 100).toInt()}%",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }
              
              return Text(
                "${realScore.toStringAsFixed(1)}% / 100% • Weight: ${(component.weightPercent * 100).toInt()}%",
              );
            },
            loading: () => const Text("Loading..."),
            error: (_,__) => const Text("Error"),
          ),
          children: [
            assessmentsAsync.when(
              data: (assessments) => Column(
                children: [
                  ...assessments.map((a) => ListTile(
                    // VISUAL DISTINCTION FOR GOALS
                    tileColor: a.isGoal ? Colors.purple.withOpacity(0.05) : null,
                    leading: a.isGoal ? const Icon(Icons.flag_circle_outlined, color: Colors.purple) : null,
                    
                    title: Text(
                      a.name,
                      style: TextStyle(
                        fontStyle: a.isGoal ? FontStyle.italic : FontStyle.normal,
                        color: a.isGoal ? Colors.purple : Colors.black,
                      ),
                    ),
                    subtitle: a.isExcused ? const Text("Excused", style: TextStyle(color: Colors.orange)) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${a.scoreObtained} / ${a.totalItems}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: a.isGoal ? Colors.purple : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () => _deleteAssessment(context, ref, a),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
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