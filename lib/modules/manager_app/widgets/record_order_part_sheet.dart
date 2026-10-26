import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../data/sample_inventory.dart';
import '../models/order_part.dart';
import '../models/part.dart';

class RecordOrderPartSheet extends StatefulWidget {
  const RecordOrderPartSheet({required this.part, super.key});

  final Part part;

  @override
  State<RecordOrderPartSheet> createState() => _RecordOrderPartSheetState();
}

class _RecordOrderPartSheetState extends State<RecordOrderPartSheet> {
  String _selectedOrderId = sampleActiveServiceOrders.first.$1;
  int _quantity = 1;

  void _confirmUsage() {
    final orderTuple = sampleActiveServiceOrders.firstWhere(
      (o) => o.$1 == _selectedOrderId,
    );
    Navigator.of(context).pop(
      OrderPart(
        id: 'op-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderTuple.$1,
        vehicleLabel: orderTuple.$2,
        partId: widget.part.id,
        partName: widget.part.name,
        partNumber: widget.part.partNumber,
        quantity: _quantity,
        unitPrice: widget.part.unitPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = widget.part.stockQuantity;

    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
          const SizedBox(height: 18),
          const Text(
            'Zarejestruj użycie części w zleceniu',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.part.name} (${widget.part.partNumber}) · Dostępne: $maxQty szt.',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedOrderId,
            decoration: const InputDecoration(
              labelText: 'Zlecenie serwisowe (order_id)',
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
            items: sampleActiveServiceOrders
                .map(
                  (o) => DropdownMenuItem(
                    value: o.$1,
                    child: Text('${o.$1} · ${o.$2}'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedOrderId = val);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ilość zużytych sztuk (automatycznie zmniejszy stan):',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text(
                '$_quantity',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: _quantity < maxQty
                    ? () => setState(() => _quantity++)
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _confirmUsage,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                'Wydaj części (${_formatCurrency(_quantity * widget.part.unitPrice)})',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) =>
    '${value.toStringAsFixed(2).replaceAll('.', ',')} zł';
