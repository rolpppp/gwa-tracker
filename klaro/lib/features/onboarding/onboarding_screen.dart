import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _selectedSystem = 'UP'; // Default

  void _finish() async {
    // Save preference
    await ref.read(preferencesProvider).completeOnboarding(_selectedSystem);

    // Navigate to Dashboard (Remove back button)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo / Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIcons.student(), size: 48, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 32),
              
              Text(
                "Welcome to Klaro: Your GWA Buddy",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Your academic GPS. Let's get you set up.",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              
              const Spacer(),
              
              const Text("Select your Grading System:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _SystemCard(
                title: "UP System",
                subtitle: "1.0 (Excellent) to 5.0 (Fail)",
                value: "UP",
                groupValue: _selectedSystem,
                onChanged: (v) => setState(() => _selectedSystem = v),
              ),
              const SizedBox(height: 12),
              _SystemCard(
                title: "US / International",
                subtitle: "A (4.0) to F (0.0)",
                value: "US",
                groupValue: _selectedSystem,
                onChanged: (v) => setState(() => _selectedSystem = v),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1F36),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Get Started", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final Function(String) onChanged;

  const _SystemCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}