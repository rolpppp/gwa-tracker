import 'package:flutter/material.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/features/course_management/logic/course_grade_provider.dart';

class GoalSimulatorModal extends StatefulWidget {
  final CourseStanding currentStanding;
  final double totalWeightUsed;

  const GoalSimulatorModal({
    super.key,
    required this.currentStanding,
    required this.totalWeightUsed,
  });

  @override
  State<GoalSimulatorModal> createState() => _GoalSimulatorModalState();
}

class _GoalSimulatorModalState extends State<GoalSimulatorModal> {
  double _hypotheticalScore = 85.0;

  @override
  Widget build(BuildContext context) {
    final remainingWeight = 1.0 - widget.totalWeightUsed;

    // Guard Clause: If semester is done (100%)
    if (remainingWeight <= 0) {
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
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "All Grades Are In!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              "You've completed 100% of the grading components.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    // Calculate projected grade
    final currentPart = widget.currentStanding.realPercentage * widget.totalWeightUsed;
    final futurePart = _hypotheticalScore * remainingWeight;
    final projectedPercent = currentPart + futurePart;
    final projectedGrade = GradingSystem.convertToUPGrade(projectedPercent);
    
    // Determine if improving or declining
    final currentGrade = widget.currentStanding.realGrade;
    final isImproving = projectedGrade < currentGrade; // Lower is better in UP system
    final isDeclining = projectedGrade > currentGrade;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            "Grade Simulator",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 4),
          Text(
            "${(remainingWeight * 100).toInt()}% of course remaining",
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Before & After Comparison
          Row(
            children: [
              // Current Grade Card
              Expanded(
                child: _GradeCard(
                  label: "Current",
                  grade: currentGrade,
                  percentage: widget.currentStanding.realPercentage,
                  color: Color(GradingSystem.getGradeColor(currentGrade)),
                  isHighlight: false,
                ),
              ),
              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.grey[400],
                  size: 28,
                ),
              ),
              // Projected Grade Card
              Expanded(
                child: _GradeCard(
                  label: "Projected",
                  grade: projectedGrade,
                  percentage: projectedPercent,
                  color: Color(GradingSystem.getGradeColor(projectedGrade)),
                  isHighlight: true,
                  changeIcon: isImproving
                      ? Icons.trending_up
                      : (isDeclining ? Icons.trending_down : null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Slider Section
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Average on remaining work",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "${_hypotheticalScore.toInt()}%",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6B46C1),
                    thumbColor: const Color(0xFF6B46C1),
                    overlayColor: const Color(0xFF6B46C1).withOpacity(0.2),
                    inactiveTrackColor: Colors.grey[300],
                    trackHeight: 6.0,
                  ),
                  child: Slider(
                    value: _hypotheticalScore,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (val) {
                      setState(() {
                        _hypotheticalScore = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                
                // Quick preset buttons
                Row(
                  children: [
                    _PresetButton(
                      label: "50%",
                      onTap: () => setState(() => _hypotheticalScore = 50),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: "75%",
                      onTap: () => setState(() => _hypotheticalScore = 75),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: "85%",
                      onTap: () => setState(() => _hypotheticalScore = 85),
                    ),
                    const SizedBox(width: 8),
                    _PresetButton(
                      label: "100%",
                      onTap: () => setState(() => _hypotheticalScore = 100),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Motivational message
          if (isImproving || isDeclining)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isImproving
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isImproving ? Icons.celebration : Icons.warning_amber,
                    color: isImproving ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMotivationText(projectedGrade, isImproving),
                      style: TextStyle(
                        color: isImproving ? Colors.green[700] : Colors.orange[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getMotivationText(double grade, bool isImproving) {
    if (grade <= 1.25) {
      return "University Scholar range! ${isImproving ? 'Keep pushing!' : 'Excellent work!'}";
    }
    if (grade <= 1.75) {
      return "College Scholar territory! ${isImproving ? 'You can do it!' : 'Great job!'}";
    }
    if (grade <= 3.00) {
      return isImproving
          ? "On track to pass! Keep the momentum going."
          : "Passing grade. Consider studying harder for remaining work.";
    }
    return "Warning: Below passing. You need strong performance on remaining work!";
  }
}

// Grade Card Widget
class _GradeCard extends StatelessWidget {
  final String label;
  final double grade;
  final double percentage;
  final Color color;
  final bool isHighlight;
  final IconData? changeIcon;

  const _GradeCard({
    required this.label,
    required this.grade,
    required this.percentage,
    required this.color,
    required this.isHighlight,
    this.changeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? color.withOpacity(0.1) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? color.withOpacity(0.4) : Theme.of(context).dividerColor,
          width: isHighlight ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (changeIcon != null) ...[
                const SizedBox(width: 4),
                Icon(changeIcon, size: 14, color: color),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            grade.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Preset Button Widget
class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}