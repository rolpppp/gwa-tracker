import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _packageInfo = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text("Contact & Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionLabel(label: "Get Support"),
          _Tile(
            icon: PhosphorIcons.envelope(PhosphorIconsStyle.duotone),
            iconColor: cs.primary,
            title: "Email Support",
            subtitle: "app.klaro@gmail.com",
            onTap: () => _launchEmail(context, 'app.klaro@gmail.com'),
          ),
          _Tile(
            icon: PhosphorIcons.discordLogo(PhosphorIconsStyle.duotone),
            iconColor: const Color(0xFF5865F2),
            title: "Discord Community",
            subtitle: "Get help from other students",
            onTap: () => _launchUrl('https://discord.gg/klaro'),
          ),
          const SizedBox(height: 22),

          _SectionLabel(label: "Send Feedback"),
          _Tile(
            icon: PhosphorIcons.bug(PhosphorIconsStyle.duotone),
            iconColor: cs.error,
            title: "Bug Reports",
            subtitle: "Help us improve Klaro",
            onTap: () => _launchEmail(context, 'app.klaro@gmail.com', subject: 'Bug Report'),
          ),
          _Tile(
            icon: PhosphorIcons.lightbulb(PhosphorIconsStyle.duotone),
            iconColor: const Color(0xFFF59E0B),
            title: "Feature Requests",
            subtitle: "Share your ideas with us",
            onTap: () => _launchEmail(context, 'app.klaro@gmail.com', subject: 'Feature Request'),
          ),
          _Tile(
            icon: PhosphorIcons.graduationCap(PhosphorIconsStyle.duotone),
            iconColor: cs.secondary,
            title: "Grading Presets",
            subtitle: "Add your university's grading system",
            onTap: () => _launchEmail(context, 'app.klaro@gmail.com', subject: 'Grading System Preset Request'),
          ),
          const SizedBox(height: 22),

          _SectionLabel(label: "Support Us"),
          _Tile(
            icon: PhosphorIcons.coffee(PhosphorIconsStyle.duotone),
            iconColor: const Color(0xFF13C3FF),
            title: "Buy Me a Coffee",
            subtitle: "Support via Ko-fi or GCash ☕",
            onTap: () => _showDonationOptionsDialog(context),
          ),
          _Tile(
            icon: PhosphorIcons.star(PhosphorIconsStyle.duotone),
            iconColor: const Color(0xFFF59E0B),
            title: "Rate on App Store",
            subtitle: "Leave a review and help us grow",
            onTap: () => _showRateDialog(context),
          ),
          const SizedBox(height: 22),

          _SectionLabel(label: "Follow Us"),
          _Tile(
            icon: PhosphorIcons.twitterLogo(PhosphorIconsStyle.duotone),
            iconColor: const Color(0xFF1DA1F2),
            title: "Twitter",
            subtitle: "@klaroapp",
            onTap: () => _launchUrl('https://twitter.com/klaroapp'),
          ),
          _Tile(
            icon: PhosphorIcons.instagramLogo(PhosphorIconsStyle.duotone),
            iconColor: const Color(0xFFE4405F),
            title: "Instagram",
            subtitle: "@klaroapp",
            onTap: () => _launchUrl('https://instagram.com/klaroapp'),
          ),
          _Tile(
            icon: PhosphorIcons.githubLogo(PhosphorIconsStyle.duotone),
            iconColor: cs.onSurfaceVariant,
            title: "GitHub",
            subtitle: "github.com/rolpppp",
            onTap: () => _launchUrl('https://github.com/rolpppp'),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              "v${_packageInfo?.version ?? '—'}  •  Made with ❤️ for students",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<void> _launchEmail(BuildContext context, String email, {String? subject}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        await Clipboard.setData(ClipboardData(text: email));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No email app found. Copied: $email')),
        );
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No email app found. Copied: $email')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rate Klaro"),
        content: const Text(
          "Thank you for using Klaro! If you're enjoying the app, please consider leaving us a rating on the App Store or Play Store.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Maybe Later")),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _launchUrl('https://apps.apple.com/app/klaro');
            },
            child: const Text("Rate Now"),
          ),
        ],
      ),
    );
  }

  void _showDonationOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.coffee(), color: Colors.brown, size: 24),
            const SizedBox(width: 12),
            const Text("Buy Me a Coffee"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Choose your preferred donation method:",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _DonationOption(
              icon: PhosphorIcons.globe(),
              title: "Ko-fi",
              subtitle: "International payments",
              color: const Color(0xFF13C3FF),
              onTap: () { Navigator.pop(ctx); _launchUrl('https://ko-fi.com/rolpppp'); },
            ),
            const SizedBox(height: 12),
            _DonationOption(
              icon: PhosphorIcons.wallet(),
              title: "GCash",
              subtitle: "Philippine payments",
              color: const Color(0xFF007DFE),
              onTap: () { Navigator.pop(ctx); _showGCashDialog(context); },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        ],
      ),
    );
  }

  void _showGCashDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.wallet(), color: const Color(0xFF007DFE), size: 24),
            const SizedBox(width: 12),
            const Text("GCash Donation"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Send your donation via GCash to:", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF007DFE).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text("GCash Number", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text("0975 185 7056", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Text("RO*F GE***E G.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text("Thank you for your support! ☕", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: "09751857056"));
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('GCash number copied to clipboard'), duration: Duration(seconds: 2)),
                );
              }
            },
            child: const Text("Copy Number"),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text("Done")),
        ],
      ),
    );
  }
}

// ── Private components ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Icon(PhosphorIcons.caretRight(), size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DonationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(PhosphorIcons.caretRight(), size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
