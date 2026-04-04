import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/core/widgets/main_navigation.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EnhancedOnboardingScreen extends ConsumerStatefulWidget {
  const EnhancedOnboardingScreen({super.key});

  @override
  ConsumerState<EnhancedOnboardingScreen> createState() => _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState extends ConsumerState<EnhancedOnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  int _currentPage = 0;
  String _selectedSystem = '5Point';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Dismiss keyboard before navigating
    FocusScope.of(context).unfocus();
    
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _previousPage() {
    // Dismiss keyboard before navigating
    FocusScope.of(context).unfocus();
    
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() async {
    await ref.read(preferencesProvider).completeOnboarding(
      _selectedSystem,
      name: _nameController.text.trim(),
      institution: _institutionController.text.trim(),
    );
    
    if (mounted) {
      // Navigate to MainNavigation and remove all previous routes
      // We use explicit navigation here instead of updating the ValueNotifier
      // to ensure the UI transition is smooth and the new Scaffold is properly initialized.
      // The change will be picked up by main.dart on next app restart.
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                physics: const NeverScrollableScrollPhysics(), // Disable swipe, use buttons
                children: [
                  _buildWelcomePage(),
                  _buildPersonalizationPage(),
                  _buildFeaturesPage(),
                  _buildGradingSystemPage(),
                ],
              ),
            ),
            
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate(target: isActive ? 1 : 0).scaleX(
              duration: 300.ms,
              curve: Curves.easeInOut,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.graduationCap(),
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          Text(
            "Welcome to Klaro",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            "Your GWA Buddy",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 20),
          
          Text(
            "Track grades, predict outcomes, and stay on top of your academic journey with ease.",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.5,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 40),
          
          _buildFeatureHighlight(
            icon: PhosphorIcons.chartLine(),
            title: "Real-time GWA tracking",
            subtitle: "See your standing instantly",
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildFeatureHighlight(
            icon: PhosphorIcons.target(),
            title: "Grade simulator",
            subtitle: "Plan what you need to achieve",
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildFeatureHighlight(
            icon: PhosphorIcons.sparkle(),
            title: "AI syllabus parser",
            subtitle: "Import grades in seconds",
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPersonalizationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.userCircle(),
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          Text(
            "Let's personalize your experience",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            "Tell us a bit about yourself (optional)",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          
          const SizedBox(height: 40),
          
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Your Name",
              hintText: "e.g., Juan dela Cruz",
              prefixIcon: Icon(PhosphorIcons.user()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? 
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            textCapitalization: TextCapitalization.words,
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 20),
          
          TextField(
            controller: _institutionController,
            decoration: InputDecoration(
              labelText: "School/University",
              hintText: "e.g., University of the Philippines",
              prefixIcon: Icon(PhosphorIcons.buildings()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? 
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            textCapitalization: TextCapitalization.words,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.info(), color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "This information stays on your device and helps personalize your experience.",
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          
          const SizedBox(height: 80), // Extra space for keyboard
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          Text(
            "Everything You Need",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 12),
          
          Text(
            "Powerful tools designed for students",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          
          const Spacer(),
          
          _buildFeatureCard(
            icon: PhosphorIcons.trendUp(),
            color: const Color(0xFF4ADE80),
            title: "Track Your Progress",
            description: "Monitor your grades across all courses and see your overall GWA update in real-time.",
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          const SizedBox(height: 20),
          
          _buildFeatureCard(
            icon: PhosphorIcons.target(),
            color: const Color(0xFF60A5FA),
            title: "Set Goals & Simulate",
            description: "Use our grade simulator to see what scores you need to hit your target GWA.",
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          const SizedBox(height: 20),
          
          _buildFeatureCard(
            icon: PhosphorIcons.sparkle(),
            color: const Color(0xFFA78BFA),
            title: "AI-Powered Import",
            description: "Upload your syllabus and let AI automatically extract grading components.",
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingSystemPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          Text(
            "Choose Your Grading System",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),

          Text(
            "Pick the one your school uses. Not sure? Check your syllabus or handbook — you can always change this in Settings later.",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _GradingSystemCard(
                    icon: "🎯",
                    title: "5-Point Scale",
                    subtitle: "1.0 (Excellent) — 5.0 (Fail). Lower is better.",
                    example: "92% → 1.25",
                    universities: const ["UP (all campuses)", "PNU", "Most State Universities"],
                    value: "5Point",
                    groupValue: _selectedSystem,
                    onChanged: (v) => setState(() => _selectedSystem = v),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  _GradingSystemCard(
                    icon: "🎓",
                    title: "4-Point Scale",
                    subtitle: "4.0 (Excellent) — 0.0 (Fail). Higher is better.",
                    example: "92% → 3.0 (Very Good)",
                    universities: const ["DLSU (La Salle)", "Mapua University"],
                    value: "4Point",
                    groupValue: _selectedSystem,
                    onChanged: (v) => setState(() => _selectedSystem = v),
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  _GradingSystemCard(
                    icon: "📝",
                    title: "US Letter Grade",
                    subtitle: "A (4.0) — F (0.0). Higher GPA is better.",
                    example: "92% → A- (3.7)",
                    universities: const ["AdMU (Ateneo)", "AIM", "International programs"],
                    value: "US",
                    groupValue: _selectedSystem,
                    onChanged: (v) => setState(() => _selectedSystem = v),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 12),

                  _CustomGradingSystemCard(
                  ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  _TransmutationInfoTile()
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: const Text(
                  "Back",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentPage == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage < 3 ? "Continue" : "Get Started",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage < 3 ? PhosphorIcons.arrowRight() : PhosphorIcons.check(),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomGradingSystemCard extends StatelessWidget {
  const _CustomGradingSystemCard();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.15),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "🛠️",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          "Custom Grading System",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "SOON",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Create your own or use community systems",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "✨ Define custom grade scales",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.lock(),
              color: Theme.of(context).disabledColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransmutationInfoTile extends StatefulWidget {
  const _TransmutationInfoTile();

  @override
  State<_TransmutationInfoTile> createState() => _TransmutationInfoTileState();
}

class _TransmutationInfoTileState extends State<_TransmutationInfoTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.question(),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Does your professor use transmutation?",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text(
                    "Transmutation adjusts your raw score before converting it to a grade. Two types are common in Philippine schools:",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTransmutationRow(
                    context,
                    label: "Base 50",
                    formula: "Transmuted = (Raw ÷ 100) × 50 + 50",
                    hint: "e.g. 70% → 85%",
                    example: "\"A score of 60 is the new 80.\"",
                  ),
                  const SizedBox(height: 8),
                  _buildTransmutationRow(
                    context,
                    label: "Base 60",
                    formula: "Transmuted = (Raw ÷ 100) × 60 + 40",
                    hint: "e.g. 70% → 82%",
                    example: "\"Passing is 60%, transmuted to 76%.\"",
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          PhosphorIcons.lightbulb(),
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "You don't need to choose now. Klaro lets you set transmutation per course after setup — just tap the course and look for the transmutation option.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransmutationRow(
    BuildContext context, {
    required String label,
    required String formula,
    required String hint,
    required String example,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hint,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            example,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradingSystemCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String example;
  final List<String> universities;
  final String value;
  final String groupValue;
  final Function(String) onChanged;

  const _GradingSystemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.example,
    required this.universities,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.08) 
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.8), width: 2.5)
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.15)
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "e.g. $example",
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: universities.map((uni) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.08)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                : Theme.of(context).dividerColor.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          uni,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.check(),
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
