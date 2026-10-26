import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class ManagerNavigationBar extends StatelessWidget {
  const ManagerNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: const Color(0xFFEAF4F2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined, color: AppColors.muted),
          selectedIcon: Icon(
            Icons.calendar_month_rounded,
            color: AppColors.teal,
          ),
          label: 'Kalendarz i stanowiska',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined, color: AppColors.muted),
          selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.teal),
          label: 'Magazyn części',
        ),
      ],
    );
  }
}
