import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klaro/features/dashboard/logic/term_repository.dart';
import 'package:klaro/features/dashboard/presentation/screens/term_management_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TermSelector extends ConsumerWidget {
  const TermSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsProvider);
    final activeTermAsync = ref.watch(activeTermProvider);

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return TextButton.icon(
            onPressed: () => _navigateToTermManagement(context),
            icon: Icon(PhosphorIcons.plus()),
            label: const Text("Add Term"),
          );
        }

        return activeTermAsync.when(
          data: (activeTerm) {
            return PopupMenuButton<int>(
              offset: const Offset(0, 40),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.calendarBlank(),
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.35,
                        ),
                        child: Text(
                          activeTerm?.name ?? "Select",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      PhosphorIcons.caretDown(),
                      size: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                ...terms.map((term) => PopupMenuItem<int>(
                  value: term.id,
                  child: Row(
                    children: [
                      if (term.isActive)
                        Icon(PhosphorIcons.check(), size: 16, color: Theme.of(context).primaryColor),
                      if (term.isActive) const SizedBox(width: 8),
                      Text(term.name),
                    ],
                  ),
                )),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: -1,
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.gear(), size: 16),
                      const SizedBox(width: 8),
                      const Text("Manage Terms"),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == -1) {
                  _navigateToTermManagement(context);
                } else {
                  ref.read(termActionsProvider).setActiveTerm(value);
                }
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text("Error"),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text("Error loading terms"),
    );
  }

  void _navigateToTermManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermManagementScreen()),
    );
  }
}
