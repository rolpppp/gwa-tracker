import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:klaro/features/dashboard/presentation/screens/term_management_screen.dart';
import 'package:klaro/features/settings/presentation/custom_grading_system_screen.dart';
import 'package:klaro/features/settings/presentation/contact_screen.dart';
import 'package:klaro/features/settings/logic/custom_grading_repository.dart';
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
                leading: Icon(PhosphorIcons.user(), size: 24),
                title: const Text("Your Name"),
                subtitle: Text(userName.isEmpty ? "Not set" : userName),
                trailing: Icon(PhosphorIcons.pencil(), size: 18),
                onTap: () => _showEditNameDialog(context),
              ),
              ListTile(
                leading: Icon(PhosphorIcons.buildings(), size: 24),
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
                    leading: Icon(PhosphorIcons.paintBrushBroad(), size: 24),
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
                leading: Icon(PhosphorIcons.palette(), size: 24),
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
              ..._buildVisibleGradingSystemTiles(currentSystem),
              ..._buildCustomSystemTiles(currentSystem),
              _buildManageGradingSystemsTile(),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            title: "Data Management",
            children: [
              ListTile(
                leading: Icon(PhosphorIcons.calendarBlank(), size: 24),
                title: const Text("Manage Terms"),
                subtitle: const Text("Add, edit, or delete semesters"),
                trailing: Icon(PhosphorIcons.caretRight(), size: 20),
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
                leading: Icon(PhosphorIcons.info(), size: 24),
                title: const Text("App Version"),
                subtitle: Text(_packageInfo?.version ?? "Loading..."),
              ),
              ListTile(
                leading: Icon(PhosphorIcons.graduationCap(), size: 24),
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
              ListTile(
                leading: Icon(PhosphorIcons.chatCircleDots(), size: 24),
                title: const Text("Contact & Support"),
                subtitle: const Text("Get help, send feedback, or support us"),
                trailing: Icon(PhosphorIcons.caretRight(), size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactScreen()),
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
                leading: Icon(PhosphorIcons.arrowClockwise(), size: 24),
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

  List<Widget> _buildVisibleGradingSystemTiles(String currentSystem) {
    final hiddenSystems = ref.watch(preferencesProvider).hiddenGradingSystems;
    final allSystems = [
      {'value': '5Point', 'label': '5-Point Scale', 'subtitle': '1.0 (Excellent) to 5.0 (Fail)'},
      {'value': '4Point', 'label': '4-Point Scale', 'subtitle': '4.0 (Excellent) to 0.0 (Fail)'},
      {'value': 'US', 'label': 'US Letter Grade', 'subtitle': 'A (4.0) to F (0.0)'},
    ];
    
    return allSystems
        .where((system) => !hiddenSystems.contains(system['value']))
        .map((system) => _buildGradingSystemTile(
              system['value'] as String,
              system['label'] as String,
              system['subtitle'] as String,
              currentSystem,
            ))
        .toList();
  }

  Widget _buildManageGradingSystemsTile() {
    return ListTile(
      leading: Icon(PhosphorIcons.wrench(), size: 24),
      title: const Text(
        "Manage Grading Systems",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: const Text(
        "Add, hide, or customize grading systems",
        style: TextStyle(fontSize: 12),
      ),
      trailing: Icon(PhosphorIcons.caretRight(), size: 20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomGradingSystemScreen()),
        );
      },
    );
  }

  List<Widget> _buildCustomSystemTiles(String currentSystem) {
    final customSystemsAsync = ref.watch(customGradingSystemsProvider);
    
    return customSystemsAsync.when(
      data: (systems) {
        return systems.map((system) {
          final systemId = 'custom_${system.id}';
          final isSelected = currentSystem == systemId;
          final isUPTacloban = system.name == "UP Tacloban";
          
          return ListTile(
            leading: isUPTacloban
                ? Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Image.asset('assets/grade_presets/up_logo.png', fit: BoxFit.contain),
                  )
                : Icon(PhosphorIcons.graduationCap(), size: 24),
            title: Text(system.name),
            subtitle: Text(
              system.isHigherBetter ? "Higher is better (GPA-style)" : "Lower is better (GWA-style)",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(PhosphorIcons.checkCircle(), size: 24, color: Theme.of(context).primaryColor)
                else
                  const SizedBox(width: 24),
              ],
            ),
            selected: isSelected,
            onTap: () async {
              await ref.read(preferencesProvider).setGradingSystem(systemId);
              setState(() {}); // Refresh to show selection
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Grading system changed to ${system.name}")),
                );
              }
            },
          );
        }).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  Widget _buildGradingSystemTile(String value, String label, String subtitle, String currentSystem) {
    final isSelected = currentSystem == value;
    
    // Helper to get icon for system
    IconData getIcon(String val) {
      switch(val) {
        case '5Point': return PhosphorIcons.chartLineUp();
        case '4Point': return PhosphorIcons.graduationCap();
        case 'US': return PhosphorIcons.textAa();
        default: return PhosphorIcons.chartBar();
      }
    }

    return ListTile(
      leading: Icon(getIcon(value), size: 24),
      title: Text(label),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              PhosphorIcons.info(),
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            tooltip: "View grading scale details",
            onPressed: () => _showGradingScaleDialog(context, value, label),
          ),
          if (isSelected)
            Icon(PhosphorIcons.checkCircle(), size: 24, color: Theme.of(context).primaryColor)
          else
            const SizedBox(width: 24),
        ],
      ),
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

  void _showGradingScaleDialog(BuildContext context, String system, String label) {
    final gradeIntervals = _getGradeIntervals(system);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              PhosphorIcons.chartLine(),
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Grading Scale",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    children: gradeIntervals.map((interval) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: interval['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                interval['grade'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                interval['range'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            if (interval['label'] != null)
                              Expanded(
                                flex: 2,
                                child: Text(
                                  interval['label'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getGradeIntervals(String system) {
    switch (system) {
      case '5Point':
        return [
          {'grade': '1.00', 'range': '96% - 100%', 'label': 'Excellent', 'color': Colors.green.shade50},
          {'grade': '1.25', 'range': '92% - 95%', 'label': 'Excellent', 'color': Colors.green.shade50},
          {'grade': '1.50', 'range': '88% - 91%', 'label': 'Very Good', 'color': Colors.lightGreen.shade50},
          {'grade': '1.75', 'range': '84% - 87%', 'label': 'Very Good', 'color': Colors.lightGreen.shade50},
          {'grade': '2.00', 'range': '80% - 83%', 'label': 'Good', 'color': Colors.lime.shade50},
          {'grade': '2.25', 'range': '75% - 79%', 'label': 'Good', 'color': Colors.lime.shade50},
          {'grade': '2.50', 'range': '70% - 74%', 'label': 'Satisfactory', 'color': Colors.yellow.shade50},
          {'grade': '2.75', 'range': '65% - 69%', 'label': 'Fair', 'color': Colors.orange.shade50},
          {'grade': '3.00', 'range': '60% - 64%', 'label': 'Pass', 'color': Colors.orange.shade50},
          {'grade': '5.00', 'range': '< 60%', 'label': 'Fail', 'color': Colors.red.shade50},
        ];
      case '4Point':
        return [
          {'grade': '4.0', 'range': '97% - 100%', 'label': 'Excellent', 'color': Colors.green.shade50},
          {'grade': '3.5', 'range': '93% - 96%', 'label': 'Superior', 'color': Colors.lightGreen.shade50},
          {'grade': '3.0', 'range': '89% - 92%', 'label': 'Very Good', 'color': Colors.lime.shade50},
          {'grade': '2.5', 'range': '85% - 88%', 'label': 'Good', 'color': Colors.yellow.shade50},
          {'grade': '2.0', 'range': '80% - 84%', 'label': 'Satisfactory', 'color': Colors.orange.shade50},
          {'grade': '1.5', 'range': '75% - 79%', 'label': 'Fair', 'color': Colors.orange.shade50},
          {'grade': '1.0', 'range': '70% - 74%', 'label': 'Pass', 'color': Colors.deepOrange.shade50},
          {'grade': '0.0', 'range': '< 70%', 'label': 'Fail', 'color': Colors.red.shade50},
        ];
      case 'US':
        return [
          {'grade': 'A', 'range': '93% - 100%', 'label': '4.0', 'color': Colors.green.shade50},
          {'grade': 'A-', 'range': '90% - 92%', 'label': '3.7', 'color': Colors.lightGreen.shade50},
          {'grade': 'B+', 'range': '87% - 89%', 'label': '3.3', 'color': Colors.lime.shade50},
          {'grade': 'B', 'range': '83% - 86%', 'label': '3.0', 'color': Colors.lime.shade50},
          {'grade': 'B-', 'range': '80% - 82%', 'label': '2.7', 'color': Colors.yellow.shade50},
          {'grade': 'C+', 'range': '77% - 79%', 'label': '2.3', 'color': Colors.yellow.shade50},
          {'grade': 'C', 'range': '73% - 76%', 'label': '2.0', 'color': Colors.orange.shade50},
          {'grade': 'C-', 'range': '70% - 72%', 'label': '1.7', 'color': Colors.orange.shade50},
          {'grade': 'D+', 'range': '67% - 69%', 'label': '1.3', 'color': Colors.deepOrange.shade50},
          {'grade': 'D', 'range': '65% - 66%', 'label': '1.0', 'color': Colors.deepOrange.shade50},
          {'grade': 'F', 'range': '< 65%', 'label': '0.0', 'color': Colors.red.shade50},
        ];
      default:
        return [];
    }
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
