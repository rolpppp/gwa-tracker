import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';
import 'package:klaro/features/dashboard/logic/term_repository.dart';
import 'package:klaro/features/course_management/presentation/course_detail_screen.dart';
import 'package:klaro/features/course_management/logic/course_grade_provider.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/core/logic/grade_display_helper.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:klaro/features/dashboard/presentation/widgets/term_selector.dart';
import 'package:klaro/core/widgets/info_dialog.dart';
import 'package:klaro/features/dashboard/logic/scholarship_provider.dart';
import 'package:klaro/core/services/notification_service.dart';

// State for toggling between Real/Projected GWA
final showRealGwaProvider = NotifierProvider<ShowRealGwaNotifier, bool>(
  ShowRealGwaNotifier.new,
);

class ShowRealGwaNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

// Change to ConsumerWidget
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Async Data from DB
    final activeTermAsync = ref.watch(activeTermProvider);
    final showRealGwa = ref.watch(showRealGwaProvider);
    final gwaAsync = showRealGwa
        ? ref.watch(realGwaProvider)
        : ref.watch(overallGwaProvider);

    final prefs = ref.watch(preferencesProvider);
    final selectedSystem = ref.watch(activeGradingSystemProvider);
    final userName = prefs.userName;
    final institution = prefs.institution;

    // Fire push notification when scholarship status crosses into at-risk territory
    ref.listen<ScholarshipStatus?>(scholarshipStatusProvider, (prev, next) {
      final wasAtRisk = prev?.isAtRisk ?? false;
      final nowAtRisk = next?.isAtRisk ?? false;
      if (!wasAtRisk && nowAtRisk && next != null) {
        NotificationService.showScholarshipAlert(
          gwaDisplay: next.gwaDisplay,
          thresholdDisplay: next.thresholdDisplay,
          isCritical: next.isCritical,
          isHigherBetter: next.isHigherBetter,
        );
      }
    });

    final scholarshipStatus = ref.watch(scholarshipStatusProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Header with GWA
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.06,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Personalized greeting
                        if (userName.isNotEmpty) ...[
                          Text(
                            "Hello, $userName!",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (institution.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              institution,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 24),
                        ] else
                          const SizedBox(height: 8),

                        // GWA Indicator
                        Center(
                          child: gwaAsync.when(
                            data: (gwa) {
                              final systemLabel =
                                  GradeDisplayHelper.getSystemLabel(
                                    selectedSystem,
                                  );
                              final label = showRealGwa
                                  ? "Real $systemLabel"
                                  : "Projected $systemLabel";

                              // If no data yet, show placeholder
                              if (gwa == null) {
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(showRealGwaProvider.notifier)
                                        .toggle();
                                  },
                                  child: CircularPercentIndicator(
                                    radius: 70.0,
                                    lineWidth: 12.0,
                                    percent: 0,
                                    center: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          GradeDisplayHelper.getSystemLabel(
                                            selectedSystem,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Text(
                                          "--",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    progressColor: Colors.grey.shade300,
                                    backgroundColor: Colors.grey.shade200,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                );
                              }

                              // Calculate percentage based on system for visual display
                              double percent;
                              if (selectedSystem == '5Point') {
                                percent = (5.0 - gwa) / 4.0;
                              } else {
                                percent = gwa / 4.0;
                              }
                              if (percent < 0) percent = 0;
                              if (percent > 1) percent = 1;

                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(showRealGwaProvider.notifier)
                                      .toggle();
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularPercentIndicator(
                                      radius: 70.0,
                                      lineWidth: 12.0,
                                      percent: percent,
                                      center: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            GradeDisplayHelper.getSystemLabel(
                                              selectedSystem,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            selectedSystem == 'US'
                                                ? GradingSystem.getUSLetter(gwa)
                                                : gwa.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                            ),
                                          ),
                                          Text(
                                            label,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      progressColor: Color(
                                        GradingSystem.getColor(gwa, selectedSystem),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                      circularStrokeCap: CircularStrokeCap.round,
                                      animation: true,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          PhosphorIcons.arrowsLeftRight(),
                                          size: 11,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Tap to switch view",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => showKlaroInfoDialog(
                                            context,
                                            title: 'How is your GWA computed?',
                                            body:
                                                'Your GWA (General Weighted Average) is calculated in three steps:\n\n'
                                                '1. Each component score (Quizzes, Exams, etc.) is computed as the sum of your earned points divided by the total possible points.\n\n'
                                                '2. Component scores are weighted by their assigned percentages and summed to produce each course\'s raw percentage.\n\n'
                                                '3. Each course\'s raw percentage is converted to a grade, then multiplied by its unit value. The GWA is the total grade-units divided by total units enrolled.\n\n'
                                                'Projected GWA includes ghost/goal assessments you added. Real GWA shows only grades you have actually earned.',
                                            formula:
                                                'Course % = Σ(Component Score × Weight)\n'
                                                'Grade    = convert(Course %)\n'
                                                'GWA      = Σ(Grade × Units) / Σ(Units)',
                                          ),
                                          child: Icon(
                                            PhosphorIcons.info(),
                                            size: 13,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox(
                              width: 140,
                              height: 140,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const Text("Error loading GWA"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Scholarship warning banner (shown when at risk)
          if (scholarshipStatus != null && scholarshipStatus.isAtRisk)
            SliverToBoxAdapter(
              child: _ScholarshipBanner(status: scholarshipStatus),
            ),

          // Semester Stats Section
          SliverToBoxAdapter(child: _SemesterStatsWidget()),

          // Course List Section with Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.06,
                16,
                MediaQuery.of(context).size.width * 0.06,
                12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "My Courses",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const TermSelector(),
                ],
              ),
            ),
          ),

          // Course List
          activeTermAsync.when(
            data: (activeTerm) {
              if (activeTerm == null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.calendarBlank(),
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No active term",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Select or create a term to get started",
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final coursesAsync = ref.watch(coursesForActiveTermProvider);

              return coursesAsync.when(
                data: (courses) {
                  if (courses.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.books(),
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No courses yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap the + button below to add your first course",
                                style: TextStyle(color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.06,
                      0,
                      MediaQuery.of(context).size.width * 0.06,
                      100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _CourseCard(course: courses[index]),
                        childCount: courses.length,
                      ),
                    ),
                  );
                },
                error: (err, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            },
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScholarshipBanner extends StatelessWidget {
  final ScholarshipStatus status;

  const _ScholarshipBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCritical = status.isCritical;
    final color = isCritical ? Colors.red.shade600 : Colors.orange.shade700;
    final bgColor = isCritical
        ? Colors.red.shade50
        : Colors.orange.shade50;
    final icon = isCritical
        ? PhosphorIcons.warningCircle()
        : PhosphorIcons.warning();

    final directionLabel = status.isHigherBetter ? 'below' : 'above';
    final body = isCritical
        ? 'Your GWA (${status.gwaDisplay}) has gone $directionLabel your threshold (${status.thresholdDisplay}). Your scholarship may be at risk!'
        : 'Your GWA (${status.gwaDisplay}) is approaching your threshold (${status.thresholdDisplay}). Stay focused!';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCritical ? 'Scholarship at Risk' : 'GWA Approaching Limit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSystem = ref.watch(activeGradingSystemProvider);
    final gradeAsync = ref.watch(courseStandingProvider(course.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 55,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(course.colorHex.replaceFirst('#', '0xFF')),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.name,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.target(),
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${course.targetGwa}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          PhosphorIcons.clock(),
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${course.units}u",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // Status chip — only shown when enough data exists
                    gradeAsync.when(
                      data: (standing) {
                        if (!standing.hasEnoughData) return const SizedBox.shrink();
                        final status = GradeDisplayHelper.getCourseStatus(
                          standing.realPercentage,
                          selectedSystem,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: _StatusChip(status: status),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              // Current grade badge
              gradeAsync.when(
                data: (standing) {
                  // If not enough data to show meaningful grade, show placeholder with context
                  if (!standing.hasEnoughData) {
                    return Tooltip(
                      message:
                          "Only ${(standing.weightGraded * 100).toStringAsFixed(0)}% graded",
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "--",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              "Grade",
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final db = ref.watch(databaseProvider);
                  return FutureBuilder<String>(
                    future: GradeDisplayHelper.formatGradeAsync(
                      standing.realPercentage,
                      selectedSystem,
                      db,
                    ),
                    builder: (context, snapshot) {
                      final numericGrade =
                          snapshot.data ??
                          standing.realPercentage.toStringAsFixed(2);

                      // For US system: show letter as primary, numeric as subtitle.
                      // For 4Point: show numeric as primary, descriptive label as subtitle.
                      // For 5Point / others: show numeric, "Grade" label.
                      final String primaryText;
                      final String subtitleText;
                      if (selectedSystem == 'US') {
                        final gpa = GradingSystem.convertToUSGrade(standing.realPercentage);
                        primaryText  = GradingSystem.getUSLetter(gpa);
                        subtitleText = numericGrade;
                      } else if (selectedSystem == '4Point') {
                        final gpa = GradingSystem.convertTo4PointGrade(standing.realPercentage);
                        primaryText  = numericGrade;
                        subtitleText = GradingSystem.get4PointLabel(gpa);
                      } else {
                        primaryText  = numericGrade;
                        subtitleText = 'Grade';
                      }

                      final gradeColor = Color(
                        GradeDisplayHelper.getGradeColorForSystem(
                          standing.realPercentage,
                          selectedSystem,
                        ),
                      );

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: gradeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              primaryText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: gradeColor,
                              ),
                            ),
                            Text(
                              subtitleText,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const SizedBox(
                  width: 35,
                  height: 35,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("--", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact chip showing a course's passing/at-risk/failing status.
class _StatusChip extends StatelessWidget {
  final CourseStatus status;
  const _StatusChip({required this.status});

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
      label = 'At Risk';
      icon  = PhosphorIcons.warning();
    } else {
      color = const Color(0xFFEF4444);
      label = 'Failing';
      icon  = PhosphorIcons.xCircle();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Semester Stats Widget
class _SemesterStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(semesterStatsProvider);

    return statsAsync.when(
      data: (stats) {
        // Don't show anything if no active term or no courses
        if (stats == null || !stats.hasData) {
          return const SizedBox.shrink();
        }

        // Calculate coverage percentage (how much of semester is graded)
        final coveragePercent = stats.courseCount > 0
            ? (stats.coursesWithGrades / stats.courseCount)
            : 0.0;
        final coverageDisplay = (coveragePercent * 100).toStringAsFixed(0);

        // Determine confidence level and messaging
        final bool isHighConfidence = coveragePercent >= 0.7;
        final bool isMediumConfidence = coveragePercent >= 0.4;
        final int pendingCount = stats.coursesWithoutGrades;

        // Confidence messaging
        String confidenceLabel;
        Color confidenceColor;
        if (isHighConfidence) {
          confidenceLabel = "High confidence";
          confidenceColor = Colors.green;
        } else if (isMediumConfidence) {
          confidenceLabel = "Building confidence";
          confidenceColor = Colors.orange;
        } else {
          confidenceLabel = "Early projection";
          confidenceColor = Colors.grey;
        }

        return Container(
          margin: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.06,
            12,
            MediaQuery.of(context).size.width * 0.06,
            4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary: Progress/Coverage Metric
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "$coverageDisplay%",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: confidenceColor,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "graded",
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: coveragePercent,
                            backgroundColor: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              confidenceColor.withOpacity(0.7),
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Confidence badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: confidenceColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHighConfidence
                              ? PhosphorIcons.checkCircle()
                              : PhosphorIcons.clockCounterClockwise(),
                          size: 14,
                          color: confidenceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          confidenceLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: confidenceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Secondary: Compact context info
              Row(
                children: [
                  Icon(
                    PhosphorIcons.books(),
                    size: 13,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${stats.courseCount} courses",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    PhosphorIcons.graduationCap(),
                    size: 13,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${stats.totalUnits.toStringAsFixed(1)} units",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const Spacer(),
                  // Action prompt
                  if (pendingCount > 0)
                    Text(
                      "$pendingCount pending",
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),

              // Tertiary: Subtle scroll hint (only when there are courses)
              if (stats.courseCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.caretDown(),
                      size: 12,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) {
        // Silent fail - don't show error UI for stats
        debugPrint('Error loading semester stats: $error');
        return const SizedBox.shrink();
      },
    );
  }
}
