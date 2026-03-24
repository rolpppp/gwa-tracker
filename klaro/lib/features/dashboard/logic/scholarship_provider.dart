import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/logic/dashboard_repository.dart';

/// Holds the current scholarship safety status.
class ScholarshipStatus {
  final double gwa;
  final double threshold;
  final bool isAtRisk;    // approaching the threshold (within 10%)
  final bool isCritical;  // has already crossed the threshold
  final String gradingSystem;

  const ScholarshipStatus({
    required this.gwa,
    required this.threshold,
    required this.isAtRisk,
    required this.isCritical,
    required this.gradingSystem,
  });

  /// True for 4-Point and US (GPA-style — higher is better).
  /// False for 5-Point (GWA-style — lower is better).
  bool get isHigherBetter => gradingSystem != '5Point';

  String get gwaDisplay {
    if (gradingSystem == 'US') {
      // Simplified display for US: just show 2 decimals
      return gwa.toStringAsFixed(2);
    }
    return gwa.toStringAsFixed(2);
  }

  String get thresholdDisplay => threshold.toStringAsFixed(2);
}

/// Returns null when scholarship mode is disabled or GWA data isn't available.
final scholarshipStatusProvider = Provider<ScholarshipStatus?>((ref) {
  final enabled = ref.watch(scholarshipModeProvider);
  if (!enabled) return null;

  final threshold = ref.watch(scholarshipThresholdProvider);
  final gradingSystem = ref.watch(activeGradingSystemProvider);
  final realGwaAsync = ref.watch(realGwaProvider);

  return realGwaAsync.when(
    data: (gwa) {
      if (gwa == null) return null;
      return ScholarshipStatus(
        gwa: gwa,
        threshold: threshold,
        isAtRisk: _isAtRisk(gwa, threshold, gradingSystem),
        isCritical: _isCritical(gwa, threshold, gradingSystem),
        gradingSystem: gradingSystem,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Approaching but not yet crossed the threshold (within 10% of threshold value).
bool _isAtRisk(double gwa, double threshold, String system) {
  final margin = threshold * 0.10;
  if (system == '5Point') {
    // Lower is better: at risk when GWA is getting close to (or above) threshold
    return gwa >= (threshold - margin);
  } else {
    // Higher is better: at risk when GWA is getting close to (or below) threshold
    return gwa <= (threshold + margin);
  }
}

/// Has already crossed the threshold (scholarship requirement violated).
bool _isCritical(double gwa, double threshold, String system) {
  if (system == '5Point') {
    return gwa > threshold;
  } else {
    return gwa < threshold;
  }
}
