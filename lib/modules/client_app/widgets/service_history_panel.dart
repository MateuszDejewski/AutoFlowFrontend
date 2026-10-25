import 'package:flutter/material.dart';

import '../models/service_order.dart';
import '../models/vehicle.dart';
import '../../../theme/app_colors.dart';

Future<void> showServiceHistoryPanel(
  BuildContext context, {
  required Vehicle vehicle,
  required List<ServiceOrder> orders,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ServiceHistoryPanel(vehicle: vehicle, orders: orders),
  );
}

class _ServiceHistoryPanel extends StatelessWidget {
  const _ServiceHistoryPanel({required this.vehicle, required this.orders});

  final Vehicle vehicle;
  final List<ServiceOrder> orders;

  @override
  Widget build(BuildContext context) {
    final history =
        orders.where((order) => order.vehicleId == vehicle.id).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
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
          const SizedBox(height: 18),
          Text(
            'Historia serwisowania',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${vehicle.brand} ${vehicle.model} · ${vehicle.registrationNumber}',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Brak historii serwisowania.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _HistoryOrderCard(order: history[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  const _HistoryOrderCard({required this.order});

  final ServiceOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.description,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          _HistoryDate(label: 'Przyjęto', date: order.createdAt),
          if (order.completedAt == null && order.deadline != null)
            _HistoryDate(label: 'Termin', date: order.deadline!),
          if (order.completedAt != null)
            _HistoryDate(label: 'Zakończono', date: order.completedAt!),
        ],
      ),
    );
  }
}

class _HistoryDate extends StatelessWidget {
  const _HistoryDate({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.muted,
            size: 13,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ${_formatDate(date)}',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ServiceOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      ServiceOrderStatus.received => (
        'Przyjęte',
        const Color(0xFFEAF0F5),
        const Color(0xFF496579),
      ),
      ServiceOrderStatus.inProgress => (
        'W trakcie',
        const Color(0xFFE8F1FF),
        const Color(0xFF356BB2),
      ),
      ServiceOrderStatus.waitingForParts => (
        'Oczekuje na części',
        const Color(0xFFFFF2D9),
        const Color(0xFF9A6A16),
      ),
      ServiceOrderStatus.ready => (
        'Gotowe do odbioru',
        const Color(0xFFE7F4ED),
        const Color(0xFF287A4D),
      ),
      ServiceOrderStatus.pickedUp => (
        'Odebrane',
        const Color(0xFFF0ECF8),
        const Color(0xFF70559A),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.'
    '${date.year}';
