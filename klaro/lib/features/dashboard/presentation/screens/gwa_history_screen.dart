import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:klaro/core/logic/grading_system.dart';
import 'package:klaro/core/logic/latin_honors_helper.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/logic/term_gwa_provider.dart';

class GwaHistoryScreen extends ConsumerWidget {
  const GwaHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSystem = ref.watch(activeGradingSystemProvider);
    final allTermsAsync = ref.watch(allTermsGwaProvider);
    final cumulativeGwa = ref.watch(cumulativeGwaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("GWA History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: allTermsAsync.when(
        data: (summaries) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // ── Cumulative GWA card ──────────────────────────────────────
              _CumulativeGwaCard(
                gwa: cumulativeGwa,
                gradingSystem: selectedSystem,
                termCount: summaries.where((s) => s.hasData).length,
                totalUnits: summaries
                    .where((s) => s.hasData)
                    .fold(0.0, (sum, s) => sum + s.totalUnits),
              ),

              const SizedBox(height: 16),

              // ── Latin Honors card ────────────────────────────────────────
              if (cumulativeGwa != null)
                _LatinHonorsCard(
                  gwa: cumulativeGwa!,
                  gradingSystem: selectedSystem,
                ),

              const SizedBox(height: 20),

              Text(
                "Per-Term Breakdown",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),

              if (summaries.isEmpty)
                _EmptyState()
              else
                ...summaries.map(
                  (s) => _TermGwaCard(
                    summary: s,
                    gradingSystem: selectedSystem,
                  ),
                ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

// ── Cumulative Card ────────────────────────────────────────────────────────

class _CumulativeGwaCard extends StatelessWidget {
  final double? gwa;
  final String gradingSystem;
  final int termCount;
  final double totalUnits;

  const _CumulativeGwaCard({
    required this.gwa,
    required this.gradingSystem,
    required this.termCount,
    required this.totalUnits,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasData = gwa != null;

    String gwaLabel;
    if (!hasData) {
      gwaLabel = "--";
    } else if (gradingSystem == 'US') {
      gwaLabel = GradingSystem.getUSLetter(gwa!);
    } else {
      gwaLabel = gwa!.toStringAsFixed(2);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.12),
            primary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.trophy(), size: 18, color: primary),
              const SizedBox(width: 8),
              Text(
                "All-time Cumulative GWA",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            gwaLabel,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: hasData
                  ? Color(GradingSystem.getColor(gwa!, gradingSystem))
                  : Colors.grey[400],
              height: 1,
            ),
          ),
          if (hasData && gradingSystem == 'US') ...[
            const SizedBox(height: 4),
            Text(
              gwa!.toStringAsFixed(2),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(
                icon: PhosphorIcons.calendarBlank(),
                label: "$termCount ${termCount == 1 ? 'term' : 'terms'}",
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: PhosphorIcons.graduationCap(),
                label: "${totalUnits.toStringAsFixed(1)} units",
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: PhosphorIcons.info(),
                label: "Real grades only",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Per-Term Card ──────────────────────────────────────────────────────────

class _TermGwaCard extends StatelessWidget {
  final TermGwaSummary summary;
  final String gradingSystem;

  const _TermGwaCard({required this.summary, required this.gradingSystem});

  @override
  Widget build(BuildContext context) {
    final isActive = summary.term.isActive;
    final hasData = summary.hasData;
    final gwa = summary.gwa;

    String gwaLabel;
    if (!hasData) {
      gwaLabel = "--";
    } else if (gradingSystem == 'US') {
      gwaLabel = GradingSystem.getUSLetter(gwa!);
    } else {
      gwaLabel = gwa!.toStringAsFixed(2);
    }

    final gradeColor = hasData
        ? Color(GradingSystem.getColor(gwa!, gradingSystem))
        : Colors.grey[400]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isActive ? 3 : 1,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isActive
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Term name + badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          summary.term.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Active",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.books(),
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${summary.courseCount} courses",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        PhosphorIcons.graduationCap(),
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${summary.totalUnits.toStringAsFixed(1)} units",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (!hasData) ...[
                    const SizedBox(height: 4),
                    Text(
                      "No grades recorded",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),

            // GWA value
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: hasData
                    ? gradeColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gwaLabel,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: hasData ? gradeColor : Colors.grey[400],
                      height: 1,
                    ),
                  ),
                  if (hasData && gradingSystem == 'US') ...[
                    const SizedBox(height: 2),
                    Text(
                      gwa!.toStringAsFixed(2),
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    "GWA",
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

// ── Latin Honors Card ──────────────────────────────────────────────────────

class _LatinHonorsCard extends StatelessWidget {
  final double gwa;
  final String gradingSystem;

  const _LatinHonorsCard({required this.gwa, required this.gradingSystem});

  @override
  Widget build(BuildContext context) {
    final currentTier = LatinHonorsHelper.getCurrentTier(gwa, gradingSystem);
    final nextTier = LatinHonorsHelper.getNextTier(gwa, gradingSystem);
    final progress = LatinHonorsHelper.progressToNextTier(gwa, gradingSystem);
    final tiers = LatinHonorsHelper.getTiers(gradingSystem);

    final accentColor = currentTier != null
        ? const Color(0xFFD97706) // amber — honors gold
        : Colors.grey.shade500;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(PhosphorIcons.medal(), size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(
                "Latin Honors Progress",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const Spacer(),
              Text(
                "Representative thresholds",
                style:
                    TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: currentTier != null
                  ? accentColor.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currentTier != null
                  ? '${currentTier.name} — currently qualifying'
                  : 'Not yet qualifying for Latin honors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: currentTier != null ? accentColor : Colors.grey[600],
              ),
            ),
          ),

          // Progress toward next tier
          if (nextTier != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Next: ${nextTier.name}",
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  "${nextTier.threshold.toStringAsFixed(2)} "
                  "${gradingSystem == '5Point' ? 'GWA or lower' : 'GPA or higher'}",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress ?? 0,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              progress != null
                  ? '${(progress * 100).toStringAsFixed(0)}% of the way there'
                  : '',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'You have reached the highest honor tier!',
              style: TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // All tiers mini-table
          ...tiers.map((tier) {
            final qualifies = tier.qualifies(gwa);
            final isCurrent = currentTier?.name == tier.name;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    isCurrent
                        ? PhosphorIcons.checkCircle()
                        : qualifies
                            ? PhosphorIcons.checkCircle()
                            : PhosphorIcons.circle(),
                    size: 14,
                    color: qualifies ? accentColor : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tier.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: qualifies
                            ? Colors.grey[800]
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  Text(
                    gradingSystem == '5Point'
                        ? '≤ ${tier.threshold.toStringAsFixed(2)}'
                        : '≥ ${tier.threshold.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: qualifies
                          ? Colors.grey[700]
                          : Colors.grey[400],
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(PhosphorIcons.calendarBlank(),
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "No terms yet",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
