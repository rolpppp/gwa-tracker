import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/logic/grade_display_helper.dart';
import 'package:klaro/core/services/preferences_service.dart';

class ComponentSimulatorModal extends ConsumerStatefulWidget {
  final int courseId;
  final double currentGrade;
  final double currentPercentage;

  const ComponentSimulatorModal({
    super.key,
    required this.courseId,
    required this.currentGrade,
    required this.currentPercentage,
  });

  @override
  ConsumerState<ComponentSimulatorModal> createState() => _ComponentSimulatorModalState();
}

class _ComponentSimulatorModalState extends ConsumerState<ComponentSimulatorModal> {
  List<GradingComponent> _components = [];
  Map<int, double> _simulatedScores = {}; // componentId -> simulated percentage
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComponents();
  }

  Future<void> _loadComponents() async {
    final db = ref.read(databaseProvider);
    final components = await (db.select(db.gradingComponents)
      ..where((c) => c.courseId.equals(widget.courseId))).get();
    
    setState(() {
      _components = components;
      // Initialize all components with 85% default
      for (var comp in components) {
        _simulatedScores[comp.id] = 85.0;
      }
      _isLoading = false;
    });
  }

  double _calculateProjectedGrade() {
    if (_components.isEmpty) return widget.currentGrade;

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (var component in _components) {
      final simulatedScore = _simulatedScores[component.id] ?? 85.0;
      totalWeightedScore += simulatedScore * component.weightPercent;
      totalWeight += component.weightPercent;
    }

    if (totalWeight == 0) return widget.currentGrade;

    final projectedPercentage = totalWeightedScore / totalWeight;
    return GradingSystem.convertToUPGrade(projectedPercentage);
  }

  double _calculateProjectedPercentage() {
    if (_components.isEmpty) return widget.currentPercentage;

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (var component in _components) {
      final simulatedScore = _simulatedScores[component.id] ?? 85.0;
      totalWeightedScore += simulatedScore * component.weightPercent;
      totalWeight += component.weightPercent;
    }

    if (totalWeight == 0) return widget.currentPercentage;
    return totalWeightedScore / totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(48),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_components.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No Components Yet",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add grading components first to simulate grades.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    final projectedGrade = _calculateProjectedGrade();
    final projectedPercentage = _calculateProjectedPercentage();
    final selectedSystem = ref.watch(preferencesProvider).selectedGradingSystem;
    final displayGrade = GradeDisplayHelper.formatGrade(projectedPercentage, selectedSystem);
    
    final isImproving = projectedGrade < widget.currentGrade;
    final isDeclining = projectedGrade > widget.currentGrade;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              Icon(Icons.science, color: Colors.purple[700]),
              const SizedBox(width: 8),
              const Text(
                "Grade Simulator",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Simulate component scores to see projected grade",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Current vs Projected Comparison
          Row(
            children: [
              Expanded(
                child: _GradeCard(
                  label: "Current",
                  grade: GradeDisplayHelper.formatGrade(widget.currentPercentage, selectedSystem),
                  percentage: widget.currentPercentage,
                  color: Color(GradeDisplayHelper.getGradeColorForSystem(widget.currentPercentage, selectedSystem)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ),
              Expanded(
                child: _GradeCard(
                  label: "Simulated",
                  grade: displayGrade,
                  percentage: projectedPercentage,
                  color: Color(GradeDisplayHelper.getGradeColorForSystem(projectedPercentage, selectedSystem)),
                  changeIcon: isImproving
                      ? Icons.trending_up
                      : (isDeclining ? Icons.trending_down : Icons.trending_flat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Component Sliders
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune, size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              "Adjust Component Scores",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._components.map((component) {
                          final score = _simulatedScores[component.id] ?? 85.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        component.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "${score.toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.purple[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Weight: ${(component.weightPercent * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 6,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                    activeTrackColor: Colors.purple[400],
                                    inactiveTrackColor: Colors.grey[300],
                                    thumbColor: Colors.purple[700],
                                    overlayColor: Colors.purple[100],
                                  ),
                                  child: Slider(
                                    value: score,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    onChanged: (value) {
                                      setState(() {
                                        _simulatedScores[component.id] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick presets
                  Text(
                    "Quick Presets",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PresetButton(
                        label: "Perfect (100%)",
                        onTap: () => _setAllScores(100),
                      ),
                      _PresetButton(
                        label: "Excellent (95%)",
                        onTap: () => _setAllScores(95),
                      ),
                      _PresetButton(
                        label: "Good (85%)",
                        onTap: () => _setAllScores(85),
                      ),
                      _PresetButton(
                        label: "Average (75%)",
                        onTap: () => _setAllScores(75),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setAllScores(double score) {
    setState(() {
      for (var component in _components) {
        _simulatedScores[component.id] = score;
      }
    });
  }
}

class _GradeCard extends StatelessWidget {
  final String label;
  final String grade;
  final double percentage;
  final Color color;
  final IconData? changeIcon;

  const _GradeCard({
    required this.label,
    required this.grade,
    required this.percentage,
    required this.color,
    this.changeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (changeIcon != null) ...[
                const SizedBox(width: 4),
                Icon(changeIcon, size: 14, color: color),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            grade,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: Colors.purple[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.purple[700]),
      ),
    );
  }
}
