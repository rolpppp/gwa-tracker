/// Philippine university Latin honors thresholds.
///
/// Based on the standard tiers used by most SUCs (UP-style 5-Point) and
/// common private-school (4-Point / US) equivalents:
///   5-Point: Summa ≤ 1.20, Magna ≤ 1.45, Cum Laude ≤ 1.75  (lower is better)
///   4-Point: Summa ≥ 3.90, Magna ≥ 3.70, Cum Laude ≥ 3.50  (higher is better)
///   US GPA:  Summa ≥ 3.90, Magna ≥ 3.70, Cum Laude ≥ 3.50  (higher is better)
///
/// These are representative thresholds — actual requirements vary by institution.

class HonorTier {
  final String name;
  final String shortName;
  final double threshold; // GWA/GPA value (NOT percentage)
  final bool isHigherBetter;

  const HonorTier({
    required this.name,
    required this.shortName,
    required this.threshold,
    required this.isHigherBetter,
  });

  /// Whether [gwa] meets this tier's requirement.
  bool qualifies(double gwa) =>
      isHigherBetter ? gwa >= threshold : gwa <= threshold;
}

class LatinHonorsHelper {
  static const _5pointTiers = [
    HonorTier(name: 'Summa Cum Laude', shortName: 'Summa', threshold: 1.20, isHigherBetter: false),
    HonorTier(name: 'Magna Cum Laude', shortName: 'Magna', threshold: 1.45, isHigherBetter: false),
    HonorTier(name: 'Cum Laude',       shortName: 'Cum Laude', threshold: 1.75, isHigherBetter: false),
  ];

  static const _4pointTiers = [
    HonorTier(name: 'Summa Cum Laude', shortName: 'Summa', threshold: 3.90, isHigherBetter: true),
    HonorTier(name: 'Magna Cum Laude', shortName: 'Magna', threshold: 3.70, isHigherBetter: true),
    HonorTier(name: 'Cum Laude',       shortName: 'Cum Laude', threshold: 3.50, isHigherBetter: true),
  ];

  /// Returns tiers ordered from hardest to easiest (Summa → Magna → Cum Laude).
  static List<HonorTier> getTiers(String gradingSystem) =>
      gradingSystem == '5Point' ? _5pointTiers : _4pointTiers;

  /// Highest tier the student currently qualifies for, or null if not qualifying.
  static HonorTier? getCurrentTier(double gwa, String gradingSystem) {
    for (final tier in getTiers(gradingSystem)) {
      if (tier.qualifies(gwa)) return tier;
    }
    return null;
  }

  /// The next harder tier above the student's current tier, or null if already Summa.
  static HonorTier? getNextTier(double gwa, String gradingSystem) {
    final tiers = getTiers(gradingSystem);
    final current = getCurrentTier(gwa, gradingSystem);

    if (current == null) {
      // Not yet qualifying — target Cum Laude (last/easiest tier)
      return tiers.last;
    }

    final currentIndex = tiers.indexWhere((t) => t.name == current.name);
    if (currentIndex <= 0) return null; // Already at Summa
    return tiers[currentIndex - 1];
  }

  /// Progress (0.0–1.0) from the current tier's threshold toward the next tier.
  /// Returns null when no qualifying tier and no meaningful starting point.
  static double? progressToNextTier(double gwa, String gradingSystem) {
    final next = getNextTier(gwa, gradingSystem);
    if (next == null) return null;

    final current = getCurrentTier(gwa, gradingSystem);
    final isHigherBetter = next.isHigherBetter;

    double from; // Starting threshold (current tier or a floor)
    double to;   // Target threshold (next tier)

    if (current == null) {
      // Not qualifying yet — use GWA 3.0/2.0 as floor so bar isn't empty
      from = isHigherBetter ? 3.0 : 2.0;
      to = next.threshold;
    } else {
      from = current.threshold;
      to = next.threshold;
    }

    if (isHigherBetter) {
      return ((gwa - from) / (to - from)).clamp(0.0, 1.0);
    } else {
      return ((from - gwa) / (from - to)).clamp(0.0, 1.0);
    }
  }

  /// Human-readable distance to the next tier threshold (e.g. "0.10 GWA away").
  static String distanceLabel(double gwa, String gradingSystem) {
    final next = getNextTier(gwa, gradingSystem);
    if (next == null) return 'You have reached the highest honor!';

    final diff = (next.threshold - gwa).abs();
    final direction = next.isHigherBetter ? 'above' : 'below';
    return '${diff.toStringAsFixed(2)} ${next.isHigherBetter ? 'GPA' : 'GWA'} '
        'points to go (target: ${next.threshold.toStringAsFixed(2)} or $direction)';
  }
}
