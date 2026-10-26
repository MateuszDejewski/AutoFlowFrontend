import 'package:flutter/material.dart';

class ManagerSummaryCard extends StatelessWidget {
  const ManagerSummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.background,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: tint, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: tint,
                    fontSize: 19,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tint.withValues(alpha: 0.85),
                    fontSize: 9,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
