import 'package:flutter/material.dart';

import '../data/sample_notifications.dart';
import '../data/sample_vehicles.dart';
import '../models/inspection_reminder.dart';
import '../../../theme/app_colors.dart';

Future<void> showNotificationsPanel(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotificationsPanel(),
  );
}

class _NotificationsPanel extends StatefulWidget {
  const _NotificationsPanel();

  @override
  State<_NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<_NotificationsPanel> {
  final _notifications = [...sampleNotifications];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE2E4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Powiadomienia',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (_notifications.isEmpty)
            _emptyState()
          else
            ..._notifications.map(_reminderCard),
        ],
      ),
    );
  }

  Widget _reminderCard(InspectionReminder reminder) {
    final matchingVehicles = sampleVehicles.where(
      (vehicle) => vehicle.id == reminder.vehicleId,
    );
    final vehicle = matchingVehicles.isEmpty ? null : matchingVehicles.first;
    final daysUntilInspection = DateUtils.dateOnly(reminder.inspectionDate)
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F4F1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  vehicle == null
                      ? 'Nieznany pojazd'
                      : '${vehicle.brand} ${vehicle.model} · ${vehicle.registrationNumber}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  reminder.description,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatDate(reminder.inspectionDate)} · za $daysUntilInspection dni',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Usuń powiadomienie',
            onPressed: () => setState(() => _notifications.remove(reminder)),
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.muted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: AppColors.muted,
            size: 28,
          ),
          SizedBox(height: 10),
          Text(
            'Brak powiadomień',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}
