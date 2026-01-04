import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/theme/app_theme.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:drift/drift.dart' hide Column;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database and seed default term
  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  
  // Check if we need to seed a default term
  final existingTerms = await db.select(db.terms).get();
  if (existingTerms.isEmpty) {
    await db.into(db.terms).insert(
      TermsCompanion.insert(
        name: 'Current Term',
        isActive: const Value(true),
      ),
    );
  }
  
  runApp(
    // Wrap the app in ProviderScope (Riverpod Requirement)
    UncontrolledProviderScope(
      container: container,
      child: const Klaro(),
    ),
  );
}

class Klaro extends StatelessWidget {
  const Klaro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klaro',
      debugShowCheckedModeBanner: false,
      // 2. Apply our "Cute" Theme
      theme: AppTheme.lightTheme,
      // 3. Set the home screen (We will create this next)
      home: const DashboardScreen(),
    );
  }
}