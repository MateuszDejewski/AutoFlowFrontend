import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/part.dart';

class PartFormSheet extends StatefulWidget {
  const PartFormSheet({this.existingPart, super.key});

  final Part? existingPart;

  @override
  State<PartFormSheet> createState() => _PartFormSheetState();
}

class _PartFormSheetState extends State<PartFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPart;
    _nameController = TextEditingController(text: p?.name ?? '');
    _numberController = TextEditingController(text: p?.partNumber ?? '');
    _quantityController = TextEditingController(
      text: p != null ? '${p.stockQuantity}' : '10',
    );
    _priceController = TextEditingController(
      text: p != null ? p.unitPrice.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final partNumber = _numberController.text.trim();
    final stock = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price =
        double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ??
        0.0;

    if (name.isEmpty || partNumber.isEmpty || price <= 0) return;

    Navigator.of(context).pop(
      Part(
        id:
            widget.existingPart?.id ??
            'part-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        partNumber: partNumber,
        stockQuantity: stock < 0 ? 0 : stock,
        unitPrice: price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPart != null;

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
      child: SingleChildScrollView(
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
            Text(
              isEditing ? 'Edytuj część' : 'Dodaj część do magazynu',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa części (name)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Numer katalogowy (part_number)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stan magazynowy (szt.)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cena jednostkowa (zł)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  isEditing ? 'Zapisz zmiany' : 'Dodaj do ewidencji',
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
      ),
    );
  }
}
