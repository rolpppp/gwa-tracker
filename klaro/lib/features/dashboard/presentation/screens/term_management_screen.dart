import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/core/services/database.dart';
import 'package:klaro/features/dashboard/logic/term_repository.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TermManagementScreen extends ConsumerWidget {
  const TermManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Terms"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: termsAsync.when(
        data: (terms) {
          if (terms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.calendarBlank(), size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No terms yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Add your first semester or term",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: terms.length,
            itemBuilder: (context, index) {
              final term = terms[index];
              return _TermCard(term: term);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTermDialog(context, ref),
        icon: Icon(PhosphorIcons.plus()),
        label: const Text("Add Term"),
      ),
    );
  }

  void _showAddTermDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Term"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Term Name",
            hintText: "e.g., 1st Sem 2025-2026",
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(termActionsProvider).addTerm(controller.text);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _TermCard extends ConsumerWidget {
  final Term term;
  
  const _TermCard({required this.term});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          term.name,
          style: TextStyle(
            fontWeight: term.isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: term.isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            PhosphorIcons.calendarCheck(),
            color: term.isActive ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        trailing: term.isActive
            ? Chip(
                label: const Text("Active", style: TextStyle(fontSize: 12)),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              )
            : PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.check(), size: 16),
                        const SizedBox(width: 8),
                        const Text("Set as Active"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.pencil(), size: 16),
                        const SizedBox(width: 8),
                        const Text("Rename"),
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
                  if (value == 'activate') {
                    ref.read(termActionsProvider).setActiveTerm(term.id);
                  } else if (value == 'edit') {
                    _showEditDialog(context, ref);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, ref);
                  }
                },
              ),
        onTap: term.isActive ? null : () {
          ref.read(termActionsProvider).setActiveTerm(term.id);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: term.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename Term"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Term Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(termActionsProvider).updateTermName(term.id, controller.text);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Term?"),
        content: Text(
          "This will permanently delete '${term.name}' and ALL courses, grades, and assessments in this term. This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(termActionsProvider).deleteTerm(term.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
