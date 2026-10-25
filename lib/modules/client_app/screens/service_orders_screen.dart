import 'package:flutter/material.dart';

import '../data/sample_vehicles.dart';
import '../data/sample_service_orders.dart';
import '../models/service_order.dart';
import '../models/vehicle.dart';
import '../navigation/client_navigation.dart';
import '../widgets/client_navigation_bar.dart';
import '../widgets/client_screen_badge.dart';
import '../widgets/notifications_panel.dart';
import '../../../theme/app_colors.dart';
import 'appointments_screen.dart';
import 'vehicles_screen.dart';

class ServiceOrdersScreen extends StatelessWidget {
  const ServiceOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehiclesById = {
      for (final vehicle in sampleVehicles) vehicle.id: vehicle,
    };

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const ClientScreenBadge(
                title: 'Śledź status zleceń',
                icon: Icons.assignment_rounded,
              ),
              const SizedBox(height: 20),
              for (final order in sampleServiceOrders)
                _ServiceOrderCard(
                  order: order,
                  vehicle: vehiclesById[order.vehicleId],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClientNavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            navigateToClientScreen(context, screen: const VehiclesScreen());
          } else if (index == 2) {
            navigateToClientScreen(context, screen: const AppointmentsScreen());
          }
        },
      ),
    );
  }
}

class _ServiceOrderCard extends StatelessWidget {
  const _ServiceOrderCard({required this.order, required this.vehicle});

  final ServiceOrder order;
  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final status = _statusPresentation(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
                  Icons.build_circle_outlined,
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
                      vehicle == null
                          ? 'Nieznany pojazd'
                          : '${vehicle!.brand} ${vehicle!.model}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (vehicle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        vehicle!.registrationNumber,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: status.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.foreground,
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
                  order.description,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 16,
                  runSpacing: 7,
                  children: [
                    _OrderDate(label: 'Przyjęto', date: order.createdAt),
                    if (order.completedAt != null)
                      _OrderDate(label: 'Zakończono', date: order.completedAt!),
                    if (order.completedAt == null && order.deadline != null)
                      _OrderDate(label: 'Termin', date: order.deadline!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusPresentation _statusPresentation(ServiceOrderStatus status) {
    return switch (status) {
      ServiceOrderStatus.received => const _StatusPresentation(
        'Przyjęte',
        Color(0xFFEAF0F5),
        Color(0xFF496579),
      ),
      ServiceOrderStatus.inProgress => const _StatusPresentation(
        'W trakcie',
        Color(0xFFE8F1FF),
        Color(0xFF356BB2),
      ),
      ServiceOrderStatus.waitingForParts => const _StatusPresentation(
        'Oczekuje na części',
        Color(0xFFFFF2D9),
        Color(0xFF9A6A16),
      ),
      ServiceOrderStatus.ready => const _StatusPresentation(
        'Gotowe do odbioru',
        Color(0xFFE7F4ED),
        Color(0xFF287A4D),
      ),
      ServiceOrderStatus.pickedUp => const _StatusPresentation(
        'Odebrane',
        Color(0xFFF0ECF8),
        Color(0xFF70559A),
      ),
    };
  }
}

class _OrderDate extends StatelessWidget {
  const _OrderDate({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          color: AppColors.muted,
          size: 13,
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $formatted',
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _StatusPresentation {
  const _StatusPresentation(this.label, this.background, this.foreground);

  final String label;
  final Color background;
  final Color foreground;
}
