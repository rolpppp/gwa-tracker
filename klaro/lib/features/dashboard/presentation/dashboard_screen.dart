import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';
import 'package:klaro/features/course_management/presentation/course_detail_screen.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:klaro/features/dashboard/presentation/widgets/add_course_modal.dart';

// Change to ConsumerWidget
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Async Data from DB
    final coursesAsync = ref.watch(coursesProvider);
    final gwaAsync = ref.watch(overallGwaProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "My Courses",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // GWA Ring Indicator
              Center(
                child: gwaAsync.when(
                  data: (gwa) {
                    // Map GWA 1.0 (Best) -> 5.0 (Worst) to Percentage 1.0 -> 0.0
                    // Simple visual mapping: 
                    // 1.0 = 100% full ring
                    // 3.0 = 50% full ring
                    // 5.0 = 0% full ring
                    double percent = (5.0 - gwa) / 4.0;
                    if (percent < 0) percent = 0;

                    return CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 15.0,
                      percent: percent,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("GWA", style: TextStyle(color: Colors.grey)),
                          Text(
                            gwa.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                          ),
                        ],
                      ),
                      progressColor: Color(GradingSystem.getGradeColor(gwa)),
                      backgroundColor: Colors.grey.shade200,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_,__) => const Text("Error"),
                ),
              ),
              const SizedBox(height: 24),

              // THE LIST OF COURSES
              Expanded(
                child: coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) return const Text("No courses yet.");
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        // Inside the ListView.builder...
return Card(
  child: ListTile(
    title: Text(course.code),
    subtitle: Text(course.name),
    trailing: Text("Target: ${course.targetGwa}"),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CourseDetailScreen(course: course),
        ),
      );
    },
  ),
);
                      },
                    );
                  },
                  error: (err, stack) => Text('Error: $err'),
                  loading: () => const CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) => const AddCourseModal(),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(PhosphorIcons.plus(), color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}