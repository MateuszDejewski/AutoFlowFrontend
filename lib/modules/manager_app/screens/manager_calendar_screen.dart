import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../data/sample_manager_appointments.dart';
import '../data/sample_work_stations.dart';
import '../models/manager_appointment.dart';
import '../models/work_station.dart';
import '../navigation/manager_navigation.dart';
import '../widgets/appointment_manager_sheet.dart';
import '../widgets/appointment_timeline_card.dart';
import '../widgets/manager_app_bar.dart';
import '../widgets/manager_navigation_bar.dart';
import '../widgets/manager_summary_card.dart';
import '../widgets/station_occupancy_card.dart';
import 'inventory_records_screen.dart';

enum _CalendarStatusFilter { all, requested, scheduled, completed, cancelled }

class ManagerCalendarScreen extends StatefulWidget {
  const ManagerCalendarScreen({super.key});

  @override
  State<ManagerCalendarScreen> createState() => _ManagerCalendarScreenState();
}

class _ManagerCalendarScreenState extends State<ManagerCalendarScreen> {
  late DateTime _selectedDay;
  late List<ManagerAppointment> _appointments;
  String? _selectedStationId;
  _CalendarStatusFilter _statusFilter = _CalendarStatusFilter.all;
  int _nextOrderCounter = 1060;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _appointments = sampleManagerAppointmentsFor(_selectedDay);
  }

  Map<String, WorkStation> get _stationsById => {
    for (final station in sampleWorkStations) station.id: station,
  };

  List<ManagerAppointment> get _filteredAppointments {
    final filtered = _appointments.where((item) {
      if (_selectedStationId != null && item.stationId != _selectedStationId) {
        return false;
      }
      return switch (_statusFilter) {
        _CalendarStatusFilter.all => true,
        _CalendarStatusFilter.requested =>
          item.status == ManagerAppointmentStatus.requested,
        _CalendarStatusFilter.scheduled =>
          item.status == ManagerAppointmentStatus.scheduled,
        _CalendarStatusFilter.completed =>
          item.status == ManagerAppointmentStatus.completed,
        _CalendarStatusFilter.cancelled =>
          item.status == ManagerAppointmentStatus.cancelled,
      };
    }).toList();

    return filtered..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> _selectDay() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 1),
      helpText: 'Wybierz dzień kalendarza',
    );
    if (selected == null || !mounted) return;

    setState(() {
      _selectedDay = DateTime(selected.year, selected.month, selected.day);
      _appointments = sampleManagerAppointmentsFor(_selectedDay);
    });
  }

  Future<void> _openAppointmentActions(ManagerAppointment item) async {
    final updated = await showModalBottomSheet<ManagerAppointment>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppointmentManagerSheet(
        appointment: item,
        stations: sampleWorkStations,
        mechanics: sampleMechanics,
        suggestedOrderNumber: 'SO-${_selectedDay.year}-$_nextOrderCounter',
      ),
    );

    if (updated == null || !mounted) return;

    setState(() {
      if (item.orderId == null && updated.orderId != null) {
        _nextOrderCounter++;
      }
      final index = _appointments.indexWhere((a) => a.id == updated.id);
      if (index != -1) {
        _appointments[index] = updated;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zaktualizowano dane wizyty.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestedCount = _appointments
        .where((a) => a.status == ManagerAppointmentStatus.requested)
        .length;
    final activeStationsCount = sampleWorkStations.where((station) {
      return _appointments.any(
        (a) =>
            a.stationId == station.id &&
            (a.status == ManagerAppointmentStatus.scheduled ||
                a.status == ManagerAppointmentStatus.requested),
      );
    }).length;

    return Scaffold(
      appBar: const ManagerAppBar(
        badgeLabel: 'KIEROWNIK',
        icon: Icons.calendar_month_rounded,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _buildHeader(
                  totalVisits: _appointments.length,
                  requestedCount: requestedCount,
                  occupiedStations: activeStationsCount,
                ),
                const SizedBox(height: 22),
                _buildStationsSection(),
                const SizedBox(height: 22),
                _buildCalendarSectionHeader(),
                const SizedBox(height: 12),
                _buildStatusFilters(),
                const SizedBox(height: 14),
                if (_filteredAppointments.isEmpty)
                  _buildEmptyState()
                else
                  for (final appointment in _filteredAppointments) ...[
                    AppointmentTimelineCard(
                      appointment: appointment,
                      stationName:
                          _stationsById[appointment.stationId]?.name ??
                          'Nieznane stanowisko',
                      onTap: () => _openAppointmentActions(appointment),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ManagerNavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            navigateToManagerScreen(
              context,
              screen: const InventoryRecordsScreen(),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader({
    required int totalVisits,
    required int requestedCount,
    required int occupiedStations,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kalendarz wizyt i stanowiska',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Zatwierdzaj rezerwacje klientów, zarządzaj czasem wizyt i otwieraj zlecenia przy przyjęciu pojazdu.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ManagerSummaryCard(
                icon: Icons.event_note_rounded,
                label: 'WIZYTY DZIŚ',
                value: '$totalVisits',
                tint: AppColors.teal,
                background: const Color(0xFFE8F3F1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ManagerSummaryCard(
                icon: Icons.pending_actions_rounded,
                label: 'DO AKCEPTACJI',
                value: '$requestedCount',
                tint: const Color(0xFFB97819),
                background: const Color(0xFFFFF3DF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ManagerSummaryCard(
                icon: Icons.home_repair_service_outlined,
                label: 'AKTYWNE STANOWISKA',
                value: '$occupiedStations/${sampleWorkStations.length}',
                tint: const Color(0xFF356BB2),
                background: const Color(0xFFE8F1FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Obłożenie stanowisk roboczych',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (_selectedStationId != null)
              TextButton(
                onPressed: () => setState(() => _selectedStationId = null),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Pokaż wszystkie',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final cardWidth = isWide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: sampleWorkStations.map((station) {
                final stationVisits =
                    _appointments
                        .where(
                          (a) =>
                              a.stationId == station.id &&
                              a.status != ManagerAppointmentStatus.cancelled,
                        )
                        .toList()
                      ..sort((a, b) => a.startTime.compareTo(b.startTime));

                final totalMinutes = stationVisits.fold<int>(
                  0,
                  (sum, item) =>
                      sum + item.endTime.difference(item.startTime).inMinutes,
                );
                final occupancyRatio = (totalMinutes / 480).clamp(0.0, 1.0);
                final isSelected = _selectedStationId == station.id;

                return SizedBox(
                  width: cardWidth,
                  child: StationOccupancyCard(
                    station: station,
                    visits: stationVisits,
                    occupancyRatio: occupancyRatio,
                    totalMinutes: totalMinutes,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedStationId = isSelected ? null : station.id;
                      });
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Harmonogram wizyt',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _selectDay,
          icon: const Icon(Icons.calendar_month_outlined, size: 17),
          label: Text(_formatDayLabel(_selectedDay)),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.teal,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    const options = [
      (_CalendarStatusFilter.all, 'Wszystkie'),
      (_CalendarStatusFilter.requested, 'Oczekujące'),
      (_CalendarStatusFilter.scheduled, 'Zaplanowane'),
      (_CalendarStatusFilter.completed, 'Zakończone'),
      (_CalendarStatusFilter.cancelled, 'Anulowane'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = options[index];
          final selected = _statusFilter == filter;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => setState(() => _statusFilter = filter),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: AppColors.teal,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? AppColors.teal : const Color(0xFFE6EAEC),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_outlined, color: AppColors.muted, size: 36),
          SizedBox(height: 10),
          Text(
            'Brak wizyt dla wybranych filtrów',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Zmień filtr statusu, stanowisko lub wybierz inny dzień w kalendarzu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

String _formatDayLabel(DateTime date) {
  const weekdays = ['pon.', 'wt.', 'śr.', 'czw.', 'pt.', 'sob.', 'niedz.'];
  const months = [
    'sty',
    'lut',
    'mar',
    'kwi',
    'maj',
    'cze',
    'lip',
    'sie',
    'wrz',
    'paź',
    'lis',
    'gru',
  ];
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return 'Dziś, ${date.day} ${months[date.month - 1]}';
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}
