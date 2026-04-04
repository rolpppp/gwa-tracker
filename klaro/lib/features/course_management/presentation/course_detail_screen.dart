import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
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
import 'package:klaro/core/widgets/info_dialog.dart';
import 'package:klaro/features/dashboard/logic/drop_simulator_provider.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(course.code),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // foregroundColor: Colors.black, // Let theme handle this
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
                value: 'drop',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.prohibit(), size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text("What if I drop?", style: TextStyle(color: Colors.orange.shade700)),
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
                if (result == true && context.mounted) {
                  // providers auto-refresh via StreamProvider
                }
              } else if (value == 'drop') {
                _showDropSimulator(context, ref, course.id);
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

  void _showDropSimulator(BuildContext context, WidgetRef ref, int courseId) {
    final future = ref.read(dropSimulatorProvider(courseId).future);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(PhosphorIcons.prohibit(), size: 20, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Expanded(child: Text("Drop Impact Simulator", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: FutureBuilder<DropImpact>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData) {
              return const Text("Unable to simulate drop impact.");
            }
            final impact = snapshot.data!;
            final isLower = impact.isLowerBetter;

            if (!impact.hasData) {
              return Text(
                "Not enough grade data to simulate dropping ${impact.courseCode} yet.",
                style: const TextStyle(fontSize: 14),
              );
            }

            final currentStr = impact.currentGwa?.toStringAsFixed(2) ?? '--';
            final simStr = impact.simulatedGwa?.toStringAsFixed(2) ?? '--';
            final improvement = impact.improvement;
            final diffStr = improvement != null
                ? '${improvement.abs().toStringAsFixed(2)} ${isLower ? 'GWA' : 'GPA'} points'
                : '--';

            final verdict = impact.dropHelps
                ? 'Dropping would IMPROVE your GWA by $diffStr.'
                : impact.dropHurts
                    ? 'Dropping would WORSEN your GWA by $diffStr.'
                    : 'Dropping would have no significant GWA impact.';

            final verdictColor = impact.dropHelps
                ? Colors.green.shade700
                : impact.dropHurts
                    ? Colors.red.shade700
                    : Colors.grey.shade700;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "If you drop ${impact.courseCode} (${impact.courseUnits.toStringAsFixed(0)} units):",
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SimRow(label: "Current GWA", value: currentStr, color: Colors.grey.shade700),
                    const SizedBox(width: 16),
                    Icon(PhosphorIcons.arrowRight(), size: 18, color: Colors.grey[400]),
                    const SizedBox(width: 16),
                    _SimRow(
                      label: "After Drop",
                      value: simStr,
                      color: impact.dropHelps ? Colors.green.shade700 : impact.dropHurts ? Colors.red.shade700 : Colors.grey.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: verdictColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: verdictColor.withOpacity(0.15)),
                  ),
                  child: Text(
                    verdict,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: verdictColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLower
                      ? "Lower GWA is better in this system."
                      : "Higher GPA is better in this system.",
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
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
            icon: Icon(PhosphorIcons.sparkle()),
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

class _CourseHeader extends ConsumerStatefulWidget {
  final Course course;
  const _CourseHeader({required this.course});

  @override
  ConsumerState<_CourseHeader> createState() => _CourseHeaderState();
}

class _CourseHeaderState extends ConsumerState<_CourseHeader> {
  late String _transmutationMode;

  @override
  void initState() {
    super.initState();
    _transmutationMode = widget.course.transmutationMode;
  }

  Future<void> _setTransmutationMode(String mode) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.courses)
      ..where((c) => c.id.equals(widget.course.id)))
      .write(CoursesCompanion(transmutationMode: Value(mode)));
    // Force provider to re-fetch with new transmutation mode
    ref.invalidate(courseStandingProvider(widget.course.id));
    setState(() => _transmutationMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

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
        color: Theme.of(context).cardColor,
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
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "--",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                "${(standing.weightGraded * 100).toStringAsFixed(0)}% graded",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  
                  // Get database for async conversion
                  final db = ref.watch(databaseProvider);

                  return FutureBuilder<List<String>>(
                    future: Future.wait([
                      GradeDisplayHelper.formatGradeAsync(standing.projectedPercentage, selectedSystem, db),
                      GradeDisplayHelper.formatGradeAsync(standing.realPercentage, selectedSystem, db),
                    ]),
                    builder: (context, snapshot) {
                      final projectedGrade = snapshot.data?[0] ?? standing.projectedPercentage.toStringAsFixed(2);
                      final realGrade = snapshot.data?[1] ?? standing.realPercentage.toStringAsFixed(2);
                      
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
                                Icon(PhosphorIcons.flag(), color: Theme.of(context).colorScheme.secondary, size: 14),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // If we have goals, show "Projected" big and "Real" small
                          if (hasGoals) ...[
                            GestureDetector(
                              onTap: () {
                                final modeLabel = _transmutationMode == 'base50'
                                    ? 'Base 50'
                                    : _transmutationMode == 'base60'
                                        ? 'Base 60'
                                        : 'None';
                                showKlaroInfoDialog(
                                  context,
                                  title: 'Grade Breakdown',
                                  body:
                                      'Projected: ${standing.projectedPercentage.toStringAsFixed(2)}%  →  $projectedGrade\n'
                                      'Real:      ${standing.realPercentage.toStringAsFixed(2)}%  →  $realGrade\n'
                                      'Transmutation: $modeLabel\n\n'
                                      'Projected includes your ghost/goal assessments. '
                                      'Real reflects only scores you have actually earned. '
                                      'Both apply the same transmutation and weighting formula.',
                                );
                              },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      projectedGrade,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary,
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
                                Icon(PhosphorIcons.info(), size: 16, color: Theme.of(context).colorScheme.secondary.withOpacity(0.6)),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard View with info icon
                        GestureDetector(
                          onTap: () {
                            final modeLabel = _transmutationMode == 'base50'
                                ? 'Base 50'
                                : _transmutationMode == 'base60'
                                    ? 'Base 60'
                                    : 'None';
                            showKlaroInfoDialog(
                              context,
                              title: 'How is this grade computed?',
                              body:
                                  'Raw percentage: ${standing.realPercentage.toStringAsFixed(2)}%\n'
                                  'Converted grade: $realGrade\n'
                                  'Transmutation: $modeLabel\n\n'
                                  'Each component\'s scores are pooled (sum of earned ÷ sum of total × 100) to get a raw %. '
                                  'If transmutation is active, that raw % is raised using the formula below before being weighted. '
                                  'Weighted component scores are then summed to give the course percentage, '
                                  'which is converted to your grading system\'s scale.',
                              formula: _transmutationMode == 'base50'
                                  ? 'Transmuted = (raw / 100) × 50 + 50\n'
                                    'Course %  = Σ(Transmuted Score × Weight)\n'
                                    'Grade     = convert(Course %)'
                                  : _transmutationMode == 'base60'
                                      ? 'Transmuted = (raw / 100) × 60 + 40\n'
                                        'Course %  = Σ(Transmuted Score × Weight)\n'
                                        'Grade     = convert(Course %)'
                                      : 'Course % = Σ(Raw Score × Weight)\n'
                                        'Grade    = convert(Course %)',
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
                                PhosphorIcons.info(),
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
                        color: standing.hasEnoughData
                            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
                            : Theme.of(context).colorScheme.tertiaryContainer?.withOpacity(0.3) ??
                              Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            standing.hasEnoughData ? PhosphorIcons.info() : PhosphorIcons.warning(),
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
          const SizedBox(height: 12),

          // Status chip row
          gradeAsync.when(
            data: (standing) {
              if (!standing.hasEnoughData) return const SizedBox.shrink();
              final status = GradeDisplayHelper.getCourseStatus(
                standing.realPercentage,
                selectedSystem,
              );
              return Align(
                alignment: Alignment.centerLeft,
                child: _CourseStatusChip(status: status),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Transmutation mode selector
          _TransmutationSelector(
            current: _transmutationMode,
            onChanged: _setTransmutationMode,
          ),

          const SizedBox(height: 16),

          // Goal Simulator Button
          componentsAsync.when(
            data: (components) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                  ),
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
                            standing: standingValue,
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
                          Icon(
                            PhosphorIcons.trendUp(),
                            color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Grade Simulator",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.purple.shade200 : Colors.purple.shade700,
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

/// Status chip shown inside the course detail header.
class _CourseStatusChip extends StatelessWidget {
  final CourseStatus status;
  const _CourseStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == CourseStatus.noData) return const SizedBox.shrink();

    final Color color;
    final String label;
    final IconData icon;

    if (status == CourseStatus.passing) {
      color = const Color(0xFF4ADE80);
      label = 'Passing';
      icon  = PhosphorIcons.checkCircle();
    } else if (status == CourseStatus.atRisk) {
      color = const Color(0xFFFACC15);
      label = 'At Risk — check your grade target';
      icon  = PhosphorIcons.warning();
    } else {
      color = const Color(0xFFEF4444);
      label = 'Failing — below passing threshold';
      icon  = PhosphorIcons.xCircle();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-style transmutation mode selector shown inside the course detail header.
///
/// Transmutation raises the floor grade so a zero raw score doesn't produce
/// a zero percentage. Common in Philippine private universities.
///
///   None (Base 0):  Transmuted = raw %
///   Base 50:        Transmuted = (raw / 100) × 50 + 50
///   Base 60:        Transmuted = (raw / 100) × 60 + 40
class _TransmutationSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _TransmutationSelector({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Transmutation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => showKlaroInfoDialog(
                context,
                title: 'What is transmutation?',
                body:
                    'Transmutation is used by many Philippine universities to raise the floor grade. '
                    'Instead of a zero raw score producing a zero percentage, the minimum grade is set to 40, 50, or another floor value.\n\n'
                    'This affects how your component scores are calculated before being weighted and converted to your final grade.\n\n'
                    'Choose the mode your professor uses. When in doubt, check your course syllabus or ask your professor.',
                formula:
                    'None (Base 0):  Grade = raw %\n'
                    'Base 50:        Grade = (raw / 100) × 50 + 50\n'
                    'Base 60:        Grade = (raw / 100) × 60 + 40\n\n'
                    'Example (raw score 70%):\n'
                    '  None   → 70.0%\n'
                    '  Base50 → 85.0%\n'
                    '  Base60 → 82.0%',
              ),
              child: Icon(
                PhosphorIcons.info(),
                size: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _TransmutationPill(label: 'None',    value: 'none',   current: current, onTap: onChanged),
            const SizedBox(width: 6),
            _TransmutationPill(label: 'Base 50', value: 'base50', current: current, onTap: onChanged),
            const SizedBox(width: 6),
            _TransmutationPill(label: 'Base 60', value: 'base60', current: current, onTap: onChanged),
          ],
        ),
      ],
    );
  }
}

class _TransmutationPill extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _TransmutationPill({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor.withOpacity(0.8) : Theme.of(context).dividerColor.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? primaryColor
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
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
        Text(value, style: TextStyle(
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        )),
      ],
    );
  }
}
/// ── Drop Simulator helper widget ──────────────────────────────────────────
class _SimRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SimRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
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
              Icon(PhosphorIcons.caretDown()),
              const SizedBox(width: 8),
              // Three-dot menu
              PopupMenuButton<String>(
                icon: Icon(PhosphorIcons.dotsThreeVertical(), size: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.pencil(), size: 18, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text('Edit Component'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.trash(), size: 18, color: Colors.red),
                        const SizedBox(width: 12),
                        const Text('Delete Component', style: TextStyle(color: Colors.red)),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " (Real: ${realScore.toStringAsFixed(1)}%) ",
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                      ),
                      TextSpan(
                        text: "• Weight: ${(component.weightPercent * 100).toInt()}%",
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
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
                    leading: a.isGoal ? Icon(PhosphorIcons.flag(), color: Colors.purple) : null,
                    
                    title: Text(
                      a.name,
                      style: TextStyle(
                        fontStyle: a.isGoal ? FontStyle.italic : FontStyle.normal,
                        color: a.isGoal ? Colors.purple : Theme.of(context).textTheme.bodyMedium?.color,
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
                            color: a.isGoal ? Colors.purple : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(PhosphorIcons.trash(), size: 18, color: Colors.red),
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
                    leading: Icon(PhosphorIcons.plus(), color: Theme.of(context).colorScheme.secondary),
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