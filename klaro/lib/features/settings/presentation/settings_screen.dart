import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/presentation/screens/term_management_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final currentSystem = ref.watch(preferencesProvider).selectedGradingSystem;
    final userName = ref.watch(preferencesProvider).userName;
    final institution = ref.watch(preferencesProvider).institution;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: "Profile",
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.user()),
                title: const Text("Your Name"),
                subtitle: Text(userName.isEmpty ? "Not set" : userName),
                trailing: Icon(PhosphorIcons.pencil(), size: 18),
                onTap: () => _showEditNameDialog(context),
              ),
              ListTile(
                leading: Icon(PhosphorIcons.buildings()),
                title: const Text("Institution"),
                subtitle: Text(institution.isEmpty ? "Not set" : institution),
                trailing: Icon(PhosphorIcons.pencil(), size: 18),
                onTap: () => _showEditInstitutionDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: "Appearance",
            children: [
              ValueListenableBuilder<String>(
                valueListenable: themeModeNotifier,
                builder: (context, currentMode, _) {
                  return ListTile(
                    leading: Icon(PhosphorIcons.paintBrushBroad()),
                    title: const Text("Theme"),
                    subtitle: Text(
                      currentMode == 'system' ? 'System Default' : 
                      currentMode == 'light' ? 'Light Mode' : 'Dark Mode'
                    ),
                    trailing: DropdownButton<String>(
                      value: currentMode,
                      underline: const SizedBox(),
                      icon: Icon(PhosphorIcons.caretDown(), size: 16),
                      items: const [
                        DropdownMenuItem(value: 'system', child: Text("System")),
                        DropdownMenuItem(value: 'light', child: Text("Light")),
                        DropdownMenuItem(value: 'dark', child: Text("Dark")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(preferencesProvider).setThemeMode(val);
                        }
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(PhosphorIcons.palette()),
                title: Row(
                  children: [
                    const Text("Custom Theme"),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                subtitle: const Text("Create your own color scheme"),
                trailing: Icon(PhosphorIcons.lockKey(), color: Colors.grey[400], size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Custom themes are coming in the next update!")),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSection(
            title: "Grading System",
            children: [
              _buildGradingSystemTile('UP', '5-Point Scale (1.0-5.0)', currentSystem),
              _buildGradingSystemTile('4Point', '4-Point GPA (0.0-4.0)', currentSystem),
              _buildGradingSystemTile('US', 'US Letter Grade (A-F)', currentSystem),
              _buildCustomGradingSystemTile(),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: "Data Management",
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.calendarBlank()),
                title: const Text("Manage Terms"),
                subtitle: const Text("Add, edit, or delete semesters"),
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermManagementScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: "About",
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.info()),
                title: const Text("App Version"),
                subtitle: Text(_packageInfo?.version ?? "Loading..."),
              ),
              ListTile(
                leading: Icon(PhosphorIcons.graduationCap()),
                title: const Text("About Klaro"),
                subtitle: const Text("GWA Tracker & Grade Simulator"),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Klaro",
                    applicationVersion: _packageInfo?.version ?? "1.0.0",
                    applicationLegalese: "© 2026 Klaro\nMade for students, by students.",
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Klaro helps you track your grades, simulate your GWA, and achieve your academic goals.",
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: "Preferences",
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.arrowClockwise()),
                title: const Text("Reset Onboarding"),
                subtitle: const Text("See the welcome screens again"),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Reset Onboarding?"),
                      content: const Text(
                        "This will show the onboarding screens next time you open the app.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Reset"),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await ref.read(preferencesProvider).resetOnboarding();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Onboarding reset! Restart the app to see it.")),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildCustomGradingSystemTile() {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text("🛠️", style: TextStyle(fontSize: 18)),
      ),
      title: Row(
        children: [
          const Flexible(
            child: Text(
              "Custom Grading System",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      subtitle: const Text(
        "Create your own or use community systems",
        style: TextStyle(fontSize: 12),
      ),
      trailing: Icon(PhosphorIcons.lockKey(), color: Colors.grey[400], size: 20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Custom grading systems are coming soon!")),
        );
      },
    );
  }

  Widget _buildGradingSystemTile(String value, String label, String currentSystem) {
    final isSelected = currentSystem == value;
    
    // Helper to get icon for system
    String getIcon(String val) {
      switch(val) {
        case 'UP': return "🎯";
        case '4Point': return "🎓";
        case 'US': return "📝";
        default: return "📊";
      }
    }

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(getIcon(value), style: const TextStyle(fontSize: 18)),
      ),
      title: Text(label),
      trailing: isSelected 
          ? Icon(PhosphorIcons.checkCircle(), color: Theme.of(context).primaryColor)
          : null,
      selected: isSelected,
      onTap: () async {
        await ref.read(preferencesProvider).setGradingSystem(value);
        setState(() {}); // Refresh to show selection
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Grading system changed to $label")),
          );
        }
      },
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: ref.read(preferencesProvider).userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Your Name",
            hintText: "e.g., Juan dela Cruz",
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(preferencesProvider).setUserName(controller.text.trim());
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditInstitutionDialog(BuildContext context) {
    final controller = TextEditingController(text: ref.read(preferencesProvider).institution);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Institution"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "School/University",
            hintText: "e.g., University of the Philippines",
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(preferencesProvider).setInstitution(controller.text.trim());
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
