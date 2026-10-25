import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/vehicle.dart';
import '../../../theme/app_colors.dart';

class BookAppointmentSheet extends StatefulWidget {
  const BookAppointmentSheet({super.key, required this.vehicles});

  final List<Vehicle> vehicles;

  @override
  State<BookAppointmentSheet> createState() => _BookAppointmentSheetState();
}

class _BookAppointmentSheetState extends State<BookAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  late String? _vehicleId;
  DateTime? _selectedDate;
  bool _showDateError = false;

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicles.isEmpty ? null : widget.vehicles.first.id;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Wybierz termin wizyty',
      cancelText: 'Anuluj',
      confirmText: 'Wybierz',
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _showDateError = false;
      });
    }
  }

  void _submit() {
    final isFormValid = _formKey.currentState!.validate();
    setState(() => _showDateError = _selectedDate == null);
    if (!isFormValid || _selectedDate == null || _vehicleId == null) return;
    Navigator.of(context).pop(
      Appointment(
        id: 'appointment-${DateTime.now().microsecondsSinceEpoch}',
        vehicleId: _vehicleId!,
        date: _selectedDate!,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
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
                const Text(
                  'Umów wizytę',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Wybierz pojazd, termin i zakres wizyty.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _vehicleId,
                  decoration: const InputDecoration(labelText: 'Pojazd'),
                  items: widget.vehicles
                      .map(
                        (vehicle) => DropdownMenuItem(
                          value: vehicle.id,
                          child: Text(
                            '${vehicle.brand} ${vehicle.model} · ${vehicle.registrationNumber}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _vehicleId = value),
                  validator: (value) =>
                      value == null ? 'Wybierz pojazd.' : null,
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Termin',
                      errorText: _showDateError
                          ? 'Wybierz termin wizyty.'
                          : null,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Wybierz datę'
                          : _formatDate(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null
                            ? AppColors.muted
                            : AppColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Zakres wizyty',
                    hintText: 'np. przegląd okresowy',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Opisz zakres wizyty.'
                      : null,
                ),
                const SizedBox(height: 20),
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
                    child: const Text(
                      'Potwierdź wizytę',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.'
    '${date.month.toString().padLeft(2, '0')}.'
    '${date.year}';
