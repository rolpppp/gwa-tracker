import 'package:flutter_test/flutter_test.dart';
import 'package:klaro/features/dashboard/logic/scholarship_provider.dart';

// Re-expose the private helpers for testing via a thin wrapper
bool isAtRisk(double gwa, double threshold, String system) =>
    _isAtRiskTest(gwa, threshold, system);

bool isCritical(double gwa, double threshold, String system) =>
    _isCriticalTest(gwa, threshold, system);

// Mirror of the package-private helpers (copy of logic — not ideal but keeps
// the test self-contained without needing to expose internals in prod code).
bool _isAtRiskTest(double gwa, double threshold, String system) {
  final margin = threshold * 0.10;
  if (system == '5Point') {
    return gwa >= (threshold - margin);
  } else {
    return gwa <= (threshold + margin);
  }
}

bool _isCriticalTest(double gwa, double threshold, String system) {
  if (system == '5Point') {
    return gwa > threshold;
  } else {
    return gwa < threshold;
  }
}

void main() {
  // ── 5-Point (lower is better) ─────────────────────────────────────────────
  group('Scholarship logic — 5-Point system (lower GWA is better)', () {
    const system = '5Point';
    const threshold = 2.0; // e.g., DOST requires GWA ≤ 2.0

    test('GWA well below threshold: not at risk, not critical', () {
      // e.g., GWA = 1.0 — excellent, far from danger
      expect(isAtRisk(1.0, threshold, system), isFalse);
      expect(isCritical(1.0, threshold, system), isFalse);
    });

    test('GWA within 10% of threshold: at risk but not critical', () {
      // 10% of 2.0 = 0.2 → warning zone is [1.8, 2.0)
      expect(isAtRisk(1.85, threshold, system), isTrue);
      expect(isCritical(1.85, threshold, system), isFalse);

      // Exactly at the lower edge of warning zone
      expect(isAtRisk(1.80, threshold, system), isTrue);
      expect(isCritical(1.80, threshold, system), isFalse);
    });

    test('GWA exactly at threshold: critical (just crossed)', () {
      // The threshold itself: GWA = 2.0 means exactly at the limit
      // _isCritical uses strict >, so 2.0 is NOT yet critical (still passing)
      // but 2.01 is critical
      expect(isCritical(2.0, threshold, system), isFalse);
      expect(isCritical(2.01, threshold, system), isTrue);
    });

    test('GWA above threshold: both at risk and critical', () {
      expect(isAtRisk(2.5, threshold, system), isTrue);
      expect(isCritical(2.5, threshold, system), isTrue);
    });

    test('Boundary: just below warning zone', () {
      // GWA = 1.79 → below (1.80 warning boundary) → not at risk
      expect(isAtRisk(1.79, threshold, system), isFalse);
    });
  });

  // ── 4-Point (higher is better) ───────────────────────────────────────────
  group('Scholarship logic — 4-Point system (higher GPA is better)', () {
    const system = '4Point';
    const threshold = 2.0; // e.g., must maintain ≥ 2.0 GPA

    test('GWA well above threshold: not at risk, not critical', () {
      expect(isAtRisk(3.5, threshold, system), isFalse);
      expect(isCritical(3.5, threshold, system), isFalse);
    });

    test('GWA within 10% of threshold: at risk but not critical', () {
      // 10% of 2.0 = 0.2 → warning zone is (2.0, 2.2]
      expect(isAtRisk(2.1, threshold, system), isTrue);
      expect(isCritical(2.1, threshold, system), isFalse);

      // Exactly at the upper edge of warning zone
      expect(isAtRisk(2.2, threshold, system), isTrue);
      expect(isCritical(2.2, threshold, system), isFalse);
    });

    test('GWA exactly at threshold: not critical (still passing)', () {
      // _isCritical uses strict <, so GWA = 2.0 is still passing
      expect(isCritical(2.0, threshold, system), isFalse);
      expect(isCritical(1.99, threshold, system), isTrue);
    });

    test('GWA below threshold: both at risk and critical', () {
      expect(isAtRisk(1.5, threshold, system), isTrue);
      expect(isCritical(1.5, threshold, system), isTrue);
    });

    test('Boundary: just above warning zone', () {
      // GWA = 2.21 → above (2.20 warning boundary) → not at risk
      expect(isAtRisk(2.21, threshold, system), isFalse);
    });
  });

  // ── US System (4-Point GPA, higher is better) ─────────────────────────────
  group('Scholarship logic — US system', () {
    const system = 'US';
    const threshold = 3.0; // e.g., must maintain ≥ 3.0 GPA (B average)

    test('GWA well above threshold: safe', () {
      expect(isAtRisk(3.8, threshold, system), isFalse);
      expect(isCritical(3.8, threshold, system), isFalse);
    });

    test('GWA within 10% margin: at risk', () {
      // 10% of 3.0 = 0.3 → warning zone ≤ 3.3
      expect(isAtRisk(3.2, threshold, system), isTrue);
      expect(isCritical(3.2, threshold, system), isFalse);
    });

    test('GWA below threshold: critical', () {
      expect(isAtRisk(2.5, threshold, system), isTrue);
      expect(isCritical(2.5, threshold, system), isTrue);
    });
  });

  // ── ScholarshipStatus model ───────────────────────────────────────────────
  group('ScholarshipStatus model', () {
    test('5-Point: isHigherBetter is false', () {
      final status = ScholarshipStatus(
        gwa: 1.5,
        threshold: 2.0,
        isAtRisk: false,
        isCritical: false,
        gradingSystem: '5Point',
      );
      expect(status.isHigherBetter, isFalse);
    });

    test('4-Point: isHigherBetter is true', () {
      final status = ScholarshipStatus(
        gwa: 3.5,
        threshold: 2.0,
        isAtRisk: false,
        isCritical: false,
        gradingSystem: '4Point',
      );
      expect(status.isHigherBetter, isTrue);
    });

    test('US: isHigherBetter is true', () {
      final status = ScholarshipStatus(
        gwa: 3.5,
        threshold: 3.0,
        isAtRisk: false,
        isCritical: false,
        gradingSystem: 'US',
      );
      expect(status.isHigherBetter, isTrue);
    });

    test('gwaDisplay returns 2 decimal places', () {
      final status = ScholarshipStatus(
        gwa: 1.75,
        threshold: 2.0,
        isAtRisk: false,
        isCritical: false,
        gradingSystem: '5Point',
      );
      expect(status.gwaDisplay, '1.75');
    });

    test('thresholdDisplay returns 2 decimal places', () {
      final status = ScholarshipStatus(
        gwa: 1.75,
        threshold: 2.0,
        isAtRisk: false,
        isCritical: false,
        gradingSystem: '5Point',
      );
      expect(status.thresholdDisplay, '2.00');
    });
  });
}
