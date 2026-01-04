import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';
import 'package:klaro/features/course_management/presentation/course_detail_screen.dart';

// Change to ConsumerWidget
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Async Data from DB
    final coursesAsync = ref.watch(coursesProvider);

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
        // ADD DUMMY DATA ON CLICK
        onPressed: () {
          ref.read(courseActionsProvider).addCourse(
            name: "Advanced Calculus", 
            code: "Math 54", 
            targetGwa: 1.75, 
            units: 5.0
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(PhosphorIcons.plus(), color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}