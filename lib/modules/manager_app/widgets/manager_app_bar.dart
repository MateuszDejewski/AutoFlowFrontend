import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class ManagerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ManagerAppBar({
    required this.badgeLabel,
    required this.icon,
    this.trailingAction,
    super.key,
  });

  final String badgeLabel;
  final IconData icon;
  final Widget? trailingAction;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.canvas,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leadingWidth: 48,
      titleSpacing: 8,
      leading: IconButton(
        tooltip: 'Wróć do wyboru makiety',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
      ),
      title: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 22),
          const SizedBox(width: 9),
          const Text(
            'AutoFlow',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            badgeLabel,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        ?trailingAction,
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFDCEFEB),
          child: Text(
            'JK',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
