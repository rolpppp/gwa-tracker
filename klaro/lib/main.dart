import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:klaro/core/theme/app_theme.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/core/widgets/main_navigation.dart';
import 'package:klaro/features/onboarding/enhanced_onboarding_screen.dart';
import 'package:drift/drift.dart' hide Column;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Load preferences before running the app
  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);
  
  // Initialize the notifier with current onboarding status
  onboardingCompleteNotifier.value = preferencesService.isOnboardingComplete;
  themeModeNotifier.value = preferencesService.themeMode;

  // Create a single container with overrides
  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(preferencesService),
    ],
  );
  
  // Initialize database and seed default term using the same container
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
    UncontrolledProviderScope(
      container: container,
      child: const KlaroApp(),
    ),
  );
}

class KlaroApp extends StatelessWidget {
  const KlaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to onboarding status changes using ValueListenableBuilder
    return ValueListenableBuilder<String>(
      valueListenable: themeModeNotifier,
      builder: (context, themeModeStr, _) {
        final mode = themeModeStr == 'light'
            ? ThemeMode.light
            : themeModeStr == 'dark'
                ? ThemeMode.dark
                : ThemeMode.system;
        
        return ValueListenableBuilder<bool>(
          valueListenable: onboardingCompleteNotifier,
          builder: (context, isComplete, _) {
            return MaterialApp(
              title: 'Klaro',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              home: isComplete ? const MainNavigation() : const EnhancedOnboardingScreen(),
            );
          },
        );
      },
    );
  }
}