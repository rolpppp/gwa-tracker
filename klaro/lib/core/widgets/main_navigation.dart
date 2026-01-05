import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:klaro/features/dashboard/presentation/dashboard_screen.dart';
import 'package:klaro/features/settings/presentation/settings_screen.dart';
import 'package:klaro/features/dashboard/presentation/widgets/add_course_modal.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (ctx) => const AddCourseModal(),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(PhosphorIcons.plus(), color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 65,
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: PhosphorIcons.house(),
                iconFilled: PhosphorIcons.house(PhosphorIconsStyle.fill),
                label: 'Dashboard',
                index: 0,
              ),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(
                icon: PhosphorIcons.gear(),
                iconFilled: PhosphorIcons.gear(PhosphorIconsStyle.fill),
                label: 'Settings',
                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required PhosphorIconData icon,
    required PhosphorIconData iconFilled,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return Flexible(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? iconFilled : icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
