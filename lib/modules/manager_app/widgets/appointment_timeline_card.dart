import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/manager_appointment.dart';

class AppointmentTimelineCard extends StatelessWidget {
  const AppointmentTimelineCard({
    required this.appointment,
    required this.stationName,
    required this.onTap,
    super.key,
  });

  final ManagerAppointment appointment;
  final String stationName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _appointmentStatusStyle(appointment.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      _formatTime(appointment.startTime),
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(appointment.endTime),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3,
                height: 108,
                margin: const EdgeInsets.only(right: 13),
                decoration: BoxDecoration(
                  color: statusStyle.foreground,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            appointment.status.label,
                            style: TextStyle(
                              color: statusStyle.foreground,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.registrationNumber}  ·  ${appointment.customerName} (${appointment.customerPhone})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaChip(
                          icon: Icons.home_repair_service_outlined,
                          label: stationName,
                        ),
                        if (appointment.orderId != null)
                          _MetaChip(
                            icon: Icons.assignment_turned_in_outlined,
                            label: 'Zlecenie: ${appointment.orderId}',
                            highlighted: true,
                          )
                        else
                          const _MetaChip(
                            icon: Icons.link_off_rounded,
                            label: 'Brak powiązanego zlecenia',
                          ),
                        if (appointment.assignedMechanic != null)
                          _MetaChip(
                            icon: Icons.engineering_outlined,
                            label: appointment.assignedMechanic!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? const Color(0xFFE8F3F1) : const Color(0xFFF4F6F7);
    final fg = highlighted ? AppColors.teal : AppColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadgeColors {
  const _StatusBadgeColors(this.background, this.foreground);
  final Color background;
  final Color foreground;
}

_StatusBadgeColors _appointmentStatusStyle(ManagerAppointmentStatus status) {
  return switch (status) {
    ManagerAppointmentStatus.requested => const _StatusBadgeColors(
      Color(0xFFFFF2D9),
      Color(0xFF9A6A16),
    ),
    ManagerAppointmentStatus.scheduled => const _StatusBadgeColors(
      Color(0xFFE8F1FF),
      Color(0xFF356BB2),
    ),
    ManagerAppointmentStatus.completed => const _StatusBadgeColors(
      Color(0xFFE7F4ED),
      Color(0xFF287A4D),
    ),
    ManagerAppointmentStatus.cancelled => const _StatusBadgeColors(
      Color(0xFFFDECEC),
      Color(0xFFB43E3E),
    ),
  };
}

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
