import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../../../theme/app_colors.dart';

class AddVehicleSheet extends StatefulWidget {
  const AddVehicleSheet({super.key, required this.existingVins, this.vehicle});

  final Set<String> existingVins;
  final Vehicle? vehicle;

  @override
  State<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _registrationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    if (vehicle == null) return;
    _brandController.text = vehicle.brand;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.productionYear.toString();
    _vinController.text = vehicle.vin;
    _registrationController.text = vehicle.registrationNumber;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Podaj $label.';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final vin = _vinController.text.trim().toUpperCase();
    if (widget.existingVins.contains(vin)) {
      _formKey.currentState!.validate();
      return;
    }
    Navigator.of(context).pop(
      Vehicle(
        id: widget.vehicle?.id ?? vin,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        productionYear: int.parse(_yearController.text.trim()),
        vin: vin,
        registrationNumber: _registrationController.text.trim().toUpperCase(),
        mileage: widget.vehicle?.mileage,
        nextInspectionDate: widget.vehicle?.nextInspectionDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                    widget.vehicle == null ? 'Dodaj pojazd' : 'Edytuj pojazd',
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.vehicle == null
                        ? 'Uzupełnij dane swojego pojazdu.'
                        : 'Zaktualizuj dane swojego pojazdu.',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _field(
                    controller: _brandController,
                    label: 'Marka',
                    hint: 'Volkswagen',
                    validator: (value) => _requiredValidator(value, 'markę'),
                  ),
                  _field(
                    controller: _modelController,
                    label: 'Model',
                    hint: 'Golf',
                    validator: (value) => _requiredValidator(value, 'model'),
                  ),
                  _field(
                    controller: _yearController,
                    label: 'Rok produkcji',
                    hint: '2020',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final requiredError = _requiredValidator(
                        value,
                        'rok produkcji',
                      );
                      if (requiredError != null) return requiredError;
                      final year = int.tryParse(value!.trim());
                      if (year == null ||
                          year < 1886 ||
                          year > DateTime.now().year + 1) {
                        return 'Podaj prawidłowy rok produkcji.';
                      }
                      return null;
                    },
                  ),
                  _field(
                    controller: _vinController,
                    label: 'Numer VIN',
                    hint: '17 znaków',
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      final requiredError = _requiredValidator(value, 'VIN');
                      if (requiredError != null) return requiredError;
                      final vin = value!.trim().toUpperCase();
                      if (vin.length != 17 ||
                          !RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin)) {
                        return 'VIN musi zawierać 17 prawidłowych znaków.';
                      }
                      if (widget.existingVins.contains(vin)) {
                        return 'Pojazd o tym numerze VIN już istnieje.';
                      }
                      return null;
                    },
                  ),
                  _field(
                    controller: _registrationController,
                    label: 'Numer rejestracyjny',
                    hint: 'WI 12345',
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) =>
                        _requiredValidator(value, 'numer rejestracyjny'),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        widget.vehicle == null
                            ? 'Zapisz pojazd'
                            : 'Zapisz zmiany',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}
