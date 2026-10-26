import 'package:flutter/material.dart';

import '../modules/client_app/client_app.dart';
import '../modules/mechanic_app/screens/mechanic_tasks_screen.dart';
import '../theme/app_colors.dart';

class MockPickerScreen extends StatelessWidget {
  const MockPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Wybierz makietę',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _MockOption(
                    icon: Icons.phone_iphone_rounded,
                    title: 'Aplikacja mobilna · Strefa klienta',
                    onTap: () => openClientApp(context),
                  ),
                  const SizedBox(height: 12),
                  _MockOption(
                    icon: Icons.desktop_windows_rounded,
                    title: 'Panel warsztatu · Zadania mechanika',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MechanicTasksScreen(),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MockOption extends StatelessWidget {
  const _MockOption({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.teal, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.teal,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
