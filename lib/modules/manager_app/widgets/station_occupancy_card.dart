import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/manager_appointment.dart';
import '../models/work_station.dart';

class StationOccupancyCard extends StatelessWidget {
  const StationOccupancyCard({
    required this.station,
    required this.visits,
    required this.occupancyRatio,
    required this.totalMinutes,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final WorkStation station;
  final List<ManagerAppointment> visits;
  final double occupancyRatio;
  final int totalMinutes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeVisits = visits
        .where(
          (v) =>
              v.status == ManagerAppointmentStatus.scheduled ||
              v.status == ManagerAppointmentStatus.requested,
        )
        .toList();
    final isFree = activeVisits.isEmpty;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final durationLabel = mins == 0 ? '${hours}h' : '${hours}h ${mins}m';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.teal : Colors.transparent,
              width: 1.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isFree
                          ? const Color(0xFFE7F4ED)
                          : const Color(0xFFEAF4F2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.home_repair_service_rounded,
                      color: isFree ? const Color(0xFF287A4D) : AppColors.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${visits.length} wizyt · obłożenie $durationLabel / 8h',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isFree
                          ? const Color(0xFFE7F4ED)
                          : const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFree ? 'Wolne' : 'W użyciu',
                      style: TextStyle(
                        color: isFree
                            ? const Color(0xFF287A4D)
                            : const Color(0xFF356BB2),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: occupancyRatio,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF0F3F4),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    occupancyRatio > 0.75
                        ? const Color(0xFFB97819)
                        : AppColors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (activeVisits.isEmpty)
                const Text(
                  'Brak zaplanowanych prac na tym stanowisku.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: activeVisits.map((v) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_formatTime(v.startTime)}–${_formatTime(v.endTime)} · ${v.registrationNumber}',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
