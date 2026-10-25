import 'package:flutter/material.dart';

class ClientNavigationBar extends StatelessWidget {
  const ClientNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 70,
      backgroundColor: Colors.white,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment_rounded),
          label: 'Zlecenia',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car_rounded),
          label: 'Pojazdy',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Wizyty',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
