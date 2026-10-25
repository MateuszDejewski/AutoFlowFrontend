import 'package:flutter/material.dart';

import '../data/sample_appointments.dart';
import '../data/sample_vehicles.dart';
import '../models/appointment.dart';
import '../models/vehicle.dart';
import '../navigation/client_navigation.dart';
import '../widgets/book_appointment_sheet.dart';
import '../widgets/client_navigation_bar.dart';
import '../widgets/client_screen_badge.dart';
import '../widgets/notifications_panel.dart';
import '../../../theme/app_colors.dart';
import 'service_orders_screen.dart';
import 'vehicles_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final List<Appointment> _appointments = [...sampleAppointments];

  Future<void> _bookAppointment() async {
    final appointment = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookAppointmentSheet(vehicles: sampleVehicles),
    );
    if (appointment == null || !mounted) return;
    setState(() => _appointments.add(appointment));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wizyta została umówiona.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesById = {
      for (final vehicle in sampleVehicles) vehicle.id: vehicle,
    };
    final appointments = [..._appointments]
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leadingWidth: 48,
        titleSpacing: 8,
        leading: IconButton(
          tooltip: 'Wróć do wyboru makiety',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Makiety',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 360)
            IconButton(
              tooltip: 'Powiadomienia',
              onPressed: () => showNotificationsPanel(context),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.ink,
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const ClientScreenBadge(
                title: 'Twoje wizyty serwisowe',
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 20),
              if (appointments.isEmpty)
                _emptyState()
              else
                for (final appointment in appointments)
                  _AppointmentCard(
                    appointment: appointment,
                    vehicle: vehiclesById[appointment.vehicleId],
                  ),
              const SizedBox(height: 8),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _bookAppointment,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Umów wizytę',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClientNavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            navigateToClientScreen(
              context,
              screen: const ServiceOrdersScreen(),
            );
          } else if (index == 1) {
            navigateToClientScreen(context, screen: const VehiclesScreen());
          }
        },
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_month_outlined, color: AppColors.muted, size: 32),
          SizedBox(height: 10),
          Text(
            'Nie masz jeszcze umówionych wizyt',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Umów wizytę, aby pojawiła się na tej liście.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.vehicle});

  final Appointment appointment;
  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final appointmentVehicle = vehicle;
    final date = appointment.date;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4F2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointmentVehicle == null
                          ? 'Nieznany pojazd'
                          : '${appointmentVehicle.brand} ${appointmentVehicle.model}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (appointmentVehicle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        appointmentVehicle.registrationNumber,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F4ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Zaplanowana',
                  style: TextStyle(
                    color: Color(0xFF287A4D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.description,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.muted,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$formattedDate · $formattedTime',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
