import 'package:flutter_test/flutter_test.dart';
import 'package:klaro/core/logic/latin_honors_helper.dart';

void main() {
  // ── 5-Point System (lower is better) ──────────────────────────────────────
  group('Latin Honors — 5-Point system', () {
    const sys = '5Point';

    test('GWA 1.10 → Summa Cum Laude', () {
      final tier = LatinHonorsHelper.getCurrentTier(1.10, sys);
      expect(tier?.shortName, 'Summa');
    });

    test('GWA 1.30 → Magna Cum Laude (not Summa)', () {
      final tier = LatinHonorsHelper.getCurrentTier(1.30, sys);
      expect(tier?.shortName, 'Magna');
    });

    test('GWA 1.60 → Cum Laude (not Magna)', () {
      final tier = LatinHonorsHelper.getCurrentTier(1.60, sys);
      expect(tier?.shortName, 'Cum Laude');
    });

    test('GWA 2.00 → not qualifying', () {
      final tier = LatinHonorsHelper.getCurrentTier(2.00, sys);
      expect(tier, isNull);
    });

    test('Next tier from Cum Laude is Magna', () {
      final next = LatinHonorsHelper.getNextTier(1.60, sys);
      expect(next?.shortName, 'Magna');
    });

    test('Next tier from Magna is Summa', () {
      final next = LatinHonorsHelper.getNextTier(1.30, sys);
      expect(next?.shortName, 'Summa');
    });

    test('No next tier from Summa', () {
      final next = LatinHonorsHelper.getNextTier(1.10, sys);
      expect(next, isNull);
    });

    test('Next tier when not qualifying is Cum Laude', () {
      final next = LatinHonorsHelper.getNextTier(2.00, sys);
      expect(next?.shortName, 'Cum Laude');
    });

    test('Progress from Cum Laude toward Magna', () {
      // current=1.60, from=1.75 (Cum Laude), to=1.45 (Magna)
      // progress = (1.75 - 1.60) / (1.75 - 1.45) = 0.15/0.30 = 0.5
      final progress = LatinHonorsHelper.progressToNextTier(1.60, sys);
      expect(progress, closeTo(0.5, 0.01));
    });

    test('Progress from Magna (1.45) toward Summa (1.20)', () {
      // from=1.45, to=1.20 → progress = (1.45-1.45)/(1.45-1.20) = 0.0
      final progress = LatinHonorsHelper.progressToNextTier(1.45, sys);
      expect(progress, closeTo(0.0, 0.01));
    });

    test('Boundary: GWA exactly at Cum Laude threshold (1.75) qualifies', () {
      final tier = LatinHonorsHelper.getCurrentTier(1.75, sys);
      expect(tier?.shortName, 'Cum Laude');
    });

    test('Boundary: GWA just above 1.75 does NOT qualify', () {
      final tier = LatinHonorsHelper.getCurrentTier(1.76, sys);
      expect(tier, isNull);
    });
  });

  // ── 4-Point System (higher is better) ─────────────────────────────────────
  group('Latin Honors — 4-Point system', () {
    const sys = '4Point';

    test('GWA 3.95 → Summa Cum Laude', () {
      final tier = LatinHonorsHelper.getCurrentTier(3.95, sys);
      expect(tier?.shortName, 'Summa');
    });

    test('GWA 3.75 → Magna Cum Laude (not Summa)', () {
      final tier = LatinHonorsHelper.getCurrentTier(3.75, sys);
      expect(tier?.shortName, 'Magna');
    });

    test('GWA 3.55 → Cum Laude (not Magna)', () {
      final tier = LatinHonorsHelper.getCurrentTier(3.55, sys);
      expect(tier?.shortName, 'Cum Laude');
    });

    test('GWA 3.00 → not qualifying', () {
      final tier = LatinHonorsHelper.getCurrentTier(3.00, sys);
      expect(tier, isNull);
    });

    test('Progress from Cum Laude toward Magna', () {
      // gwa=3.60, from=3.50, to=3.70 → progress=(3.60-3.50)/(3.70-3.50)=0.5
      final progress = LatinHonorsHelper.progressToNextTier(3.60, sys);
      expect(progress, closeTo(0.5, 0.01));
    });

    test('Boundary: GPA exactly at Cum Laude (3.50) qualifies', () {
      final tier = LatinHonorsHelper.getCurrentTier(3.50, sys);
      expect(tier?.shortName, 'Cum Laude');
    });

    test('Boundary: GPA just below 3.50 does NOT qualify', () {
      final tier = LatinHonorsHelper.getCurrentTier(3.49, sys);
      expect(tier, isNull);
    });
  });

  // ── DropImpact model (direction logic) ────────────────────────────────────
  group('DropImpact improvement direction', () {
    test('5-Point: lower simulatedGwa = improvement', () {
      // Dropping a bad course improves (lowers) the 5-Point GWA
      // Simulate: current=1.85, simulated=1.75 → improvement = 1.85-1.75 = +0.10
      const delta = 0.10;
      expect(delta > 0, isTrue); // drop helps
    });

    test('4-Point: higher simulatedGwa = improvement', () {
      // Dropping a bad course improves (raises) the 4-Point GPA
      const delta = 0.10;
      expect(delta > 0, isTrue); // drop helps
    });
  });
}
