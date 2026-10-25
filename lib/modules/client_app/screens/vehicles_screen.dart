import 'package:flutter/material.dart';

import '../data/sample_vehicles.dart';
import '../data/sample_service_orders.dart';
import '../models/vehicle.dart';
import '../navigation/client_navigation.dart';
import '../widgets/add_vehicle_sheet.dart';
import '../widgets/client_navigation_bar.dart';
import '../widgets/client_screen_badge.dart';
import '../widgets/notifications_panel.dart';
import '../widgets/service_history_panel.dart';
import '../../../theme/app_colors.dart';
import 'appointments_screen.dart';
import 'service_orders_screen.dart';

enum _VehicleAction { serviceHistory, view, edit, delete }

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.'
    '${date.year}';

class _VehicleMenuOption extends StatelessWidget {
  const _VehicleMenuOption({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final List<Vehicle> _vehicles = [...sampleVehicles];

  Future<void> _showAddVehicleForm() async {
    final vehicle = await showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddVehicleSheet(
        existingVins: _vehicles.map((vehicle) => vehicle.vin).toSet(),
      ),
    );
    if (vehicle == null || !mounted) return;
    setState(() => _vehicles.insert(0, vehicle));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dodano pojazd ${vehicle.brand} ${vehicle.model}.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editVehicle(Vehicle currentVehicle) async {
    final updatedVehicle = await showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddVehicleSheet(
        vehicle: currentVehicle,
        existingVins: _vehicles
            .where((vehicle) => vehicle.id != currentVehicle.id)
            .map((vehicle) => vehicle.vin)
            .toSet(),
      ),
    );
    if (updatedVehicle == null || !mounted) return;
    setState(() {
      final index = _vehicles.indexWhere(
        (vehicle) => vehicle.id == currentVehicle.id,
      );
      if (index != -1) _vehicles[index] = updatedVehicle;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Zaktualizowano dane ${updatedVehicle.brand} ${updatedVehicle.model}.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showVehicleDetails(Vehicle vehicle) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleDetailsSheet(vehicle: vehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        centerTitle: false,
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
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _welcomeCard(),
                    const SizedBox(height: 26),
                    if (_vehicles.isEmpty) ...[
                      _emptyResults(),
                    ] else
                      ..._vehicles.map(_vehicleCard),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _showAddVehicleForm,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          'Dodaj pojazd',
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClientNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            navigateToClientScreen(
              context,
              screen: const ServiceOrdersScreen(),
            );
          } else if (index == 2) {
            navigateToClientScreen(context, screen: const AppointmentsScreen());
          }
        },
      ),
    );
  }

  Widget _welcomeCard() {
    return const ClientScreenBadge(
      title: 'Zarządzaj swoimi pojazdami',
      icon: Icons.directions_car_filled_rounded,
    );
  }

  Widget _vehicleCard(Vehicle vehicle) {
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
                  Icons.directions_car_filled_rounded,
                  color: AppColors.teal,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vehicle.registrationNumber,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_VehicleAction>(
                tooltip: 'Opcje pojazdu',
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.black.withValues(alpha: 0.18),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.muted,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _VehicleAction.serviceHistory:
                      showServiceHistoryPanel(
                        context,
                        vehicle: vehicle,
                        orders: sampleServiceOrders,
                      );
                      break;
                    case _VehicleAction.view:
                      _showVehicleDetails(vehicle);
                      break;
                    case _VehicleAction.edit:
                      _editVehicle(vehicle);
                      break;
                    case _VehicleAction.delete:
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _VehicleAction.serviceHistory,
                    child: _VehicleMenuOption(
                      icon: Icons.history_rounded,
                      label: 'Historia serwisowania',
                    ),
                  ),
                  PopupMenuItem(
                    value: _VehicleAction.view,
                    child: _VehicleMenuOption(
                      icon: Icons.info_outline_rounded,
                      label: 'Podgląd informacji',
                    ),
                  ),
                  PopupMenuItem(
                    value: _VehicleAction.edit,
                    child: _VehicleMenuOption(
                      icon: Icons.edit_outlined,
                      label: 'Edytuj dane',
                    ),
                  ),
                  PopupMenuItem(
                    value: _VehicleAction.delete,
                    child: _VehicleMenuOption(
                      icon: Icons.delete_outline_rounded,
                      label: 'Usuń pojazd',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (vehicle.nextInspectionDate != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.teal,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Następny przegląd: ${_formatDate(vehicle.nextInspectionDate!)}',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyResults() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppColors.muted, size: 34),
          SizedBox(height: 10),
          Text(
            'Nie masz jeszcze pojazdów',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Dodaj pojazd, aby umawiać wizyty serwisowe.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _VehicleDetailsSheet extends StatelessWidget {
  const _VehicleDetailsSheet({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE2E4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _VehicleDetailRow(label: 'Marka', value: vehicle.brand),
            _VehicleDetailRow(label: 'Model', value: vehicle.model),
            _VehicleDetailRow(
              label: 'Rok produkcji',
              value: '${vehicle.productionYear}',
            ),
            _VehicleDetailRow(
              label: 'Numer rejestracyjny',
              value: vehicle.registrationNumber,
            ),
            _VehicleDetailRow(label: 'VIN', value: vehicle.vin),
            _VehicleDetailRow(
              label: 'Aktualny przebieg',
              value: vehicle.mileage == null
                  ? 'Brak danych'
                  : '${vehicle.mileage} km',
            ),
            _VehicleDetailRow(
              label: 'Następny przegląd',
              value: vehicle.nextInspectionDate == null
                  ? 'Brak danych'
                  : _formatDate(vehicle.nextInspectionDate!),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDetailRow extends StatelessWidget {
  const _VehicleDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
