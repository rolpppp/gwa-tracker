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

// State for toggling between Real/Projected GWA
final showRealGwaProvider = NotifierProvider<ShowRealGwaNotifier, bool>(ShowRealGwaNotifier.new);

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
    final gwaAsync = showRealGwa ? ref.watch(realGwaProvider) : ref.watch(overallGwaProvider);
    
    final prefs = ref.watch(preferencesProvider);
    final selectedSystem = ref.watch(activeGradingSystemProvider);
    final userName = prefs.userName;
    final institution = prefs.institution;

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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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
                              final systemLabel = GradeDisplayHelper.getSystemLabel(selectedSystem);
                              final label = showRealGwa ? "Real $systemLabel" : "Projected $systemLabel";
                              
                              // If no data yet, show placeholder
                              if (gwa == null) {
                                return GestureDetector(
                                  onTap: () {
                                  ref.read(showRealGwaProvider.notifier).toggle();
                                },
                                  child: CircularPercentIndicator(
                                    radius: 70.0,
                                    lineWidth: 12.0,
                                    percent: 0,
                                    center: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          GradeDisplayHelper.getSystemLabel(selectedSystem),
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                        const Text(
                                          "--",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.grey),
                                        ),
                                        Text(
                                          label,
                                          style: const TextStyle(color: Colors.grey, fontSize: 10),
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
                                  ref.read(showRealGwaProvider.notifier).toggle();
                                },
                                child: CircularPercentIndicator(
                                  radius: 70.0,
                                  lineWidth: 12.0,
                                  percent: percent,
                                  center: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        GradeDisplayHelper.getSystemLabel(selectedSystem),
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      Text(
                                        selectedSystem == 'US' 
                                          ? GradingSystem.getUSLetter(gwa)
                                          : gwa.toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                                      ),
                                      Text(
                                        label,
                                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  progressColor: Color(GradingSystem.getColor(gwa, selectedSystem)),
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey.shade800 
                                      : Colors.grey.shade200,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation: true,
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
                          Icon(PhosphorIcons.calendarBlank(), size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No active term",
                            style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w600),
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
                              Icon(PhosphorIcons.books(), size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                "No courses yet",
                                style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w600),
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
                    child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
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
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                  color: Color(int.parse(course.colorHex.replaceFirst('#', '0xFF'))),
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(PhosphorIcons.target(), size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          "${course.targetGwa}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(PhosphorIcons.clock(), size: 13, color: Colors.grey[500]),
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
                      message: "Only ${(standing.weightGraded * 100).toStringAsFixed(0)}% graded",
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  
                  final grade = GradeDisplayHelper.formatGrade(
                    standing.realPercentage,
                    selectedSystem,
                  );
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(GradeDisplayHelper.getGradeColorForSystem(
                        standing.realPercentage,
                        selectedSystem,
                      )).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          grade,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(GradeDisplayHelper.getGradeColorForSystem(
                              standing.realPercentage,
                              selectedSystem,
                            )),
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
