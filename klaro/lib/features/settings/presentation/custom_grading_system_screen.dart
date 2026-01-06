import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/features/settings/logic/custom_grading_repository.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/core/services/preferences_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomGradingSystemScreen extends ConsumerStatefulWidget {
  const CustomGradingSystemScreen({super.key});

  @override
  ConsumerState<CustomGradingSystemScreen> createState() => _CustomGradingSystemScreenState();
}

class _CustomGradingSystemScreenState extends ConsumerState<CustomGradingSystemScreen> {
  @override
  Widget build(BuildContext context) {
    final systemsAsync = ref.watch(customGradingSystemsProvider);
    final hiddenSystems = ref.watch(preferencesProvider).hiddenGradingSystems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Grading Systems"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "preset",
            onPressed: _showPresetsDialog,
            icon: Icon(PhosphorIcons.download()),
            label: const Text("Use Presets"),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "create",
            onPressed: _showCreateSystemDialog,
            icon: Icon(PhosphorIcons.plus()),
            label: const Text("New System"),
          ),
        ],
      ),
      body: systemsAsync.when(
        data: (customSystems) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Built-in Systems Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.package(), size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      "Built-in Systems",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              _buildBuiltInSystemTile('5Point', '5-Point Scale', '1.0 - 5.0', hiddenSystems),
              _buildBuiltInSystemTile('4Point', '4-Point Scale', '0.0 - 4.0', hiddenSystems),
              _buildBuiltInSystemTile('US', 'US Letter Grade', 'A - F', hiddenSystems),
              
              const SizedBox(height: 24),
              
              // Custom Systems Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.wrench(), size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      "Custom Systems",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (customSystems.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(PhosphorIcons.graduationCap(), size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          "No custom systems yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Create a custom grading system or load a preset",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...customSystems.map((system) => _buildCustomSystemTile(system)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBuiltInSystemTile(String value, String label, String scale, List<String> hiddenSystems) {
    final isVisible = !hiddenSystems.contains(value);
    
    IconData getIcon(String val) {
      switch(val) {
        case '5Point': return PhosphorIcons.chartLineUp();
        case '4Point': return PhosphorIcons.graduationCap();
        case 'US': return PhosphorIcons.textAa();
        default: return PhosphorIcons.chartBar();
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            getIcon(value),
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          scale,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(
            isVisible ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash(),
            color: isVisible ? Theme.of(context).primaryColor : Colors.grey,
            size: 24,
          ),
          tooltip: isVisible ? "Hide system" : "Show system",
          onPressed: () async {
            await ref.read(preferencesProvider).toggleGradingSystemVisibility(value);
            setState(() {});
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isVisible ? "$label hidden" : "$label shown"),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomSystemTile(CustomGradingSystem system) {
    final isUPTacloban = system.name == "UP Tacloban";
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isUPTacloban ? Colors.white : Colors.purple.shade100,
            shape: BoxShape.circle,
            border: isUPTacloban ? Border.all(color: Colors.grey.shade300) : null,
          ),
          child: isUPTacloban
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset('assets/grade_presets/up_logo.png', fit: BoxFit.contain),
                )
              : Icon(
                  PhosphorIcons.graduationCap(),
                  color: Colors.purple.shade700,
                  size: 20,
                ),
        ),
        title: Text(system.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          system.isHigherBetter ? "Higher is better (GPA-style)" : "Lower is better (GWA-style)",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton(
          icon: Icon(PhosphorIcons.dotsThreeVertical()),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(PhosphorIcons.pencil(), size: 16),
                  const SizedBox(width: 8),
                  const Text("Edit Name"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'manage',
              child: Row(
                children: [
                  Icon(PhosphorIcons.list(), size: 16),
                  const SizedBox(width: 8),
                  const Text("Manage Scales"),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(PhosphorIcons.trash(), size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text("Delete", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditSystemDialog(context, ref, system);
            } else if (value == 'manage') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomGradingScalesScreen(system: system),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteSystemDialog(context, ref, system);
            }
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomGradingScalesScreen(system: system),
            ),
          );
        },
      ),
    );
  }

  void _showPresetsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.graduationCap(), color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Expanded(child: Text("Grading System Presets")),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Image.asset('assets/grade_presets/up_logo.png', fit: BoxFit.contain),
                ),
                title: const Text(
                  "UP Tacloban",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "1.0 (Excellent) to 5.0 (Failed)\n11 grade intervals",
                  style: TextStyle(fontSize: 12),
                ),
                isThreeLine: true,
                trailing: Icon(PhosphorIcons.caretRight()),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _loadUPTaclobanPreset();
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(PhosphorIcons.lightbulb(), size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Want to see your university's grading system here? Send us a request and we'll add it to the presets!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Future<void> _loadUPTaclobanPreset() async {
    try {
      // Create the system
      final systemId = await ref.read(customGradingActionsProvider).createSystem(
        name: "UP Tacloban",
        isHigherBetter: false, // Lower is better (GWA-style)
      );

      // Add all the grade scales based on the UP Tacloban table
      final scales = [
        {'min': 98.0, 'grade': 1.0, 'label': 'Excellent'},
        {'min': 94.0, 'grade': 1.25, 'label': 'Excellent'},
        {'min': 90.0, 'grade': 1.5, 'label': 'Very Good'},
        {'min': 85.0, 'grade': 1.75, 'label': 'Very Good'},
        {'min': 80.0, 'grade': 2.0, 'label': 'Good'},
        {'min': 75.0, 'grade': 2.25, 'label': 'Good'},
        {'min': 70.0, 'grade': 2.5, 'label': 'Satisfactory'},
        {'min': 65.0, 'grade': 2.75, 'label': 'Satisfactory'},
        {'min': 60.0, 'grade': 3.0, 'label': 'Passed'},
        {'min': 50.0, 'grade': 4.0, 'label': 'Conditional Failure'},
        {'min': 0.0, 'grade': 5.0, 'label': 'Failed'},
      ];

      for (final scale in scales) {
        await ref.read(customGradingActionsProvider).addScale(
          systemId: systemId,
          minPercentage: scale['min'] as double,
          gradeValue: scale['grade'] as double,
          gradeLabel: scale['label'] as String,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset('assets/grade_presets/up_logo.png', fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text("UP Tacloban grading system loaded successfully!")),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading preset: $e")),
        );
      }
    }
  }

  void _showCreateSystemDialog() {
    final nameController = TextEditingController();
    bool isHigherBetter = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Create Grading System"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "System Name",
                  hintText: "e.g., My University GPA",
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Higher is better"),
                subtitle: Text(
                  isHigherBetter 
                    ? "Like GPA (4.0 is best)"
                    : "Like GWA (1.0 is best)",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                value: isHigherBetter,
                onChanged: (val) => setState(() => isHigherBetter = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a system name")),
                  );
                  return;
                }

                try {
                  await ref.read(customGradingActionsProvider).createSystem(
                    name: nameController.text.trim(),
                    isHigherBetter: isHigherBetter,
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Grading system created!")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSystemDialog(BuildContext context, WidgetRef ref, CustomGradingSystem system) {
    final nameController = TextEditingController(text: system.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit System Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "System Name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a system name")),
                );
                return;
              }

              await ref.read(customGradingActionsProvider).updateSystem(
                system.id,
                nameController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("System updated!")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteSystemDialog(BuildContext context, WidgetRef ref, CustomGradingSystem system) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete System?"),
        content: Text("Are you sure you want to delete '${system.name}'? This will also delete all its grade scales."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(customGradingActionsProvider).deleteSystem(system.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("System deleted")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class CustomGradingScalesScreen extends ConsumerWidget {
  final CustomGradingSystem system;

  const CustomGradingScalesScreen({super.key, required this.system});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scalesAsync = ref.watch(customGradingScalesProvider(system.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(system.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScaleDialog(context, ref),
        icon: Icon(PhosphorIcons.plus()),
        label: const Text("Add Scale"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(PhosphorIcons.info(), color: Colors.purple.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Grade Scales",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Define percentage ranges and their corresponding grade values. "
                  "The system is ${system.isHigherBetter ? 'higher-is-better' : 'lower-is-better'}.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Expanded(
            child: scalesAsync.when(
              data: (scales) {
                if (scales.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.chartBar(), size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No scales defined",
                            style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add grade scales to define how percentages convert to grades",
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Sort scales by minPercentage descending
                final sortedScales = List<CustomGradingScale>.from(scales)
                  ..sort((a, b) => b.minPercentage.compareTo(a.minPercentage));

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Header
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                "Percentage Range",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Text(
                                "Grade Value",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Text(
                                "Label",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Table Rows
                      ...sortedScales.asMap().entries.map((entry) {
                        final index = entry.key;
                        final scale = entry.value;
                        
                        // Calculate range display (lower bound - upper bound)
                        String rangeDisplay;
                        if (index == 0) {
                          // First entry (highest minPercentage) goes up to 100%
                          rangeDisplay = "${scale.minPercentage.toStringAsFixed(0)}% - 100%";
                        } else {
                          // Other entries: from current min to previous min - 0.01
                          final prevMin = sortedScales[index - 1].minPercentage;
                          rangeDisplay = "${scale.minPercentage.toStringAsFixed(0)}% - ${(prevMin - 0.01).toStringAsFixed(0)}%";
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => _showEditScaleDialog(context, ref, scale),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                child: Row(
                                  children: [
                                    // Percentage Range
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        rangeDisplay,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    
                                    // Grade Value
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        child: Text(
                                          scale.gradeValue.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Label
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        scale.gradeLabel ?? "-",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: scale.gradeLabel != null 
                                              ? Colors.grey.shade700 
                                              : Colors.grey.shade400,
                                          fontStyle: scale.gradeLabel == null 
                                              ? FontStyle.italic 
                                              : FontStyle.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    
                                    // Actions
                                    SizedBox(
                                      width: 48,
                                      child: PopupMenuButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          PhosphorIcons.dotsThreeVertical(),
                                          size: 20,
                                          color: Colors.grey.shade600,
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(PhosphorIcons.pencil(), size: 16),
                                                const SizedBox(width: 8),
                                                const Text("Edit"),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(PhosphorIcons.trash(), size: 16, color: Colors.red),
                                                const SizedBox(width: 8),
                                                const Text("Delete", style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditScaleDialog(context, ref, scale);
                                          } else if (value == 'delete') {
                                            _showDeleteScaleDialog(context, ref, scale);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddScaleDialog(BuildContext context, WidgetRef ref) {
    final percentageController = TextEditingController();
    final gradeValueController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Grade Scale"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: percentageController,
                decoration: const InputDecoration(
                  labelText: "Minimum Percentage",
                  hintText: "e.g., 96",
                  border: OutlineInputBorder(),
                  suffixText: "%",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gradeValueController,
                decoration: const InputDecoration(
                  labelText: "Grade Value",
                  hintText: "e.g., 1.00 or 4.0",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: "Label (Optional)",
                  hintText: "e.g., A, Excellent",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final percentage = double.tryParse(percentageController.text.trim());
              final gradeValue = double.tryParse(gradeValueController.text.trim());

              if (percentage == null || gradeValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter valid numbers")),
                );
                return;
              }

              if (percentage < 0 || percentage > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Percentage must be between 0 and 100")),
                );
                return;
              }

              await ref.read(customGradingActionsProvider).addScale(
                systemId: system.id,
                minPercentage: percentage,
                gradeValue: gradeValue,
                gradeLabel: labelController.text.trim().isEmpty ? null : labelController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Grade scale added!")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditScaleDialog(BuildContext context, WidgetRef ref, CustomGradingScale scale) {
    final percentageController = TextEditingController(text: scale.minPercentage.toString());
    final gradeValueController = TextEditingController(text: scale.gradeValue.toString());
    final labelController = TextEditingController(text: scale.gradeLabel ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Grade Scale"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: percentageController,
                decoration: const InputDecoration(
                  labelText: "Minimum Percentage",
                  border: OutlineInputBorder(),
                  suffixText: "%",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gradeValueController,
                decoration: const InputDecoration(
                  labelText: "Grade Value",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: "Label (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final percentage = double.tryParse(percentageController.text.trim());
              final gradeValue = double.tryParse(gradeValueController.text.trim());

              if (percentage == null || gradeValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter valid numbers")),
                );
                return;
              }

              if (percentage < 0 || percentage > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Percentage must be between 0 and 100")),
                );
                return;
              }

              await ref.read(customGradingActionsProvider).updateScale(
                id: scale.id,
                minPercentage: percentage,
                gradeValue: gradeValue,
                gradeLabel: labelController.text.trim().isEmpty ? null : labelController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Grade scale updated!")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteScaleDialog(BuildContext context, WidgetRef ref, CustomGradingScale scale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Scale?"),
        content: Text("Are you sure you want to delete this grade scale (${scale.minPercentage.toStringAsFixed(0)}% → ${scale.gradeValue})?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(customGradingActionsProvider).deleteScale(scale.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Scale deleted")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
