import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact & Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.chatCircleDots(),
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  "We'd Love to Hear from You!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Whether it's support, feedback, or just saying hi",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSection(
            context,
            title: "Get Support",
            icon: PhosphorIcons.lifebuoy(),
            iconColor: Colors.blue,
            children: [
              _buildContactTile(
                context,
                icon: PhosphorIcons.envelope(),
                title: "Email Support",
                subtitle: "app.klaro@gmail.com",
                onTap: () => _launchEmail(context, 'app.klaro@gmail.com'),
              ),
              _buildContactTile(
                context,
                icon: PhosphorIcons.discordLogo(),
                title: "Join Discord Community",
                subtitle: "Get help from other students",
                onTap: () => _launchUrl('https://discord.gg/klaro'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Feedback Section
          _buildSection(
            context,
            title: "Send Feedback",
            icon: PhosphorIcons.megaphone(),
            iconColor: Colors.orange,
            children: [
              _buildContactTile(
                context,
                icon: PhosphorIcons.bug(),
                title: "Report a Bug",
                subtitle: "Help us improve Klaro",
                onTap: () => _launchEmail(
                  context,
                  'app.klaro@gmail.com',
                  subject: 'Bug Report',
                ),
              ),
              _buildContactTile(
                context,
                icon: PhosphorIcons.lightbulb(),
                title: "Feature Request",
                subtitle: "Share your ideas with us",
                onTap: () => _launchEmail(
                  context,
                  'app.klaro@gmail.com',
                  subject: 'Feature Request',
                ),
              ),
              _buildContactTile(
                context,
                icon: PhosphorIcons.graduationCap(),
                title: "Request Grading Preset",
                subtitle: "Add your university's grading system",
                onTap: () => _launchEmail(
                  context,
                  'app.klaro@gmail.com',
                  subject: 'Grading System Preset Request',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Support Us Section
          _buildSection(
            context,
            title: "Support Us",
            icon: PhosphorIcons.heart(),
            iconColor: Colors.red,
            children: [
              _buildContactTile(
                context,
                icon: PhosphorIcons.coffee(),
                title: "Buy Me a Coffee",
                subtitle: "Support via Ko-fi ☕",
                onTap: () => _showDonationOptionsDialog(context),
              ),
              _buildContactTile(
                context,
                icon: PhosphorIcons.star(),
                title: "Rate on App Store",
                subtitle: "Leave a review and help us grow",
                onTap: () => _showRateDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Social Media Section
          _buildSection(
            context,
            title: "Follow Us",
            icon: PhosphorIcons.shareNetwork(),
            iconColor: Colors.purple,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialButton(
                      context,
                      icon: PhosphorIcons.twitterLogo(),
                      label: "Twitter",
                      color: const Color(0xFF1DA1F2),
                      onTap: () => _launchUrl('https://twitter.com/klaroapp'),
                    ),
                    _buildSocialButton(
                      context,
                      icon: PhosphorIcons.instagramLogo(),
                      label: "Instagram",
                      color: const Color(0xFFE4405F),
                      onTap: () => _launchUrl('https://instagram.com/klaroapp'),
                    ),
                    _buildSocialButton(
                      context,
                      icon: PhosphorIcons.githubLogo(),
                      label: "GitHub",
                      color: const Color(0xFF333333),
                      onTap: () => _launchUrl('https://github.com/rolpppp'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  "Made with ❤️ for students",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "© 2026 Klaro. All rights reserved.",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Icon(PhosphorIcons.caretRight(), size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context, String email, {String? subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );
    
    try {
      // Try to launch with external application mode
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // Fallback: copy email to clipboard
        await Clipboard.setData(ClipboardData(text: email));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No email app found. Email copied: $email'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: copy email to clipboard
      await Clipboard.setData(ClipboardData(text: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No email app found. Email copied: $email'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently or show a message
    }
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Maybe Later"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Add actual app store links
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
            _buildDonationOption(
              context,
              icon: PhosphorIcons.globe(),
              title: "Ko-fi",
              subtitle: "International payments",
              color: const Color(0xFF13C3FF),
              onTap: () {
                Navigator.pop(ctx);
                _launchUrl('https://ko-fi.com/rolpppp');
              },
            ),
            const SizedBox(height: 12),
            _buildDonationOption(
              context,
              icon: PhosphorIcons.wallet(),
              title: "GCash",
              subtitle: "Philippine payments",
              color: const Color(0xFF007DFE),
              onTap: () {
                Navigator.pop(ctx);
                _showGCashDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIcons.caretRight(), size: 20, color: Colors.grey),
            ],
          ),
        ),
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
            const Text(
              "Send your donation via GCash to:",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF007DFE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF007DFE).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "GCash Number",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "0975 185 7056",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "RO*F GE***E G.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Thank you for your support! ☕",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: "09XXXXXXXXX"));
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GCash number copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text("Copy Number"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
