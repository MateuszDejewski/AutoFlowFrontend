import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../models/manager_appointment.dart';
import '../models/work_station.dart';

class AppointmentManagerSheet extends StatefulWidget {
  const AppointmentManagerSheet({
    required this.appointment,
    required this.stations,
    required this.mechanics,
    required this.suggestedOrderNumber,
    super.key,
  });

  final ManagerAppointment appointment;
  final List<WorkStation> stations;
  final List<String> mechanics;
  final String suggestedOrderNumber;

  @override
  State<AppointmentManagerSheet> createState() =>
      _AppointmentManagerSheetState();
}

class _AppointmentManagerSheetState extends State<AppointmentManagerSheet> {
  late ManagerAppointmentStatus _status;
  late String _stationId;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _createOrUpdateOrder;
  late String _selectedMechanic;
  late OrderPriority _priority;
  late final TextEditingController _mileageController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    _status = a.status;
    _stationId = a.stationId;
    _startTime = TimeOfDay.fromDateTime(a.startTime);
    _endTime = TimeOfDay.fromDateTime(a.endTime);
    _createOrUpdateOrder = a.orderId != null;
    _selectedMechanic = a.assignedMechanic ?? widget.mechanics.first;
    _priority = a.priority ?? OrderPriority.normal;
    _mileageController = TextEditingController(
      text: a.mileageAtIntake?.toString() ?? '95000',
    );
    _descriptionController = TextEditingController(text: a.description);
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _confirmAndSave({bool approveRequested = false}) {
    final baseDate = widget.appointment.startTime;
    final newStart = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    var newEnd = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    if (!newEnd.isAfter(newStart)) {
      newEnd = newStart.add(const Duration(hours: 1));
    }

    final effectiveStatus = approveRequested
        ? ManagerAppointmentStatus.scheduled
        : _status;

    final orderId = _createOrUpdateOrder
        ? (widget.appointment.orderId ?? widget.suggestedOrderNumber)
        : widget.appointment.orderId;

    Navigator.of(context).pop(
      widget.appointment.copyWith(
        stationId: _stationId,
        status: effectiveStatus,
        startTime: newStart,
        endTime: newEnd,
        description: _descriptionController.text.trim(),
        orderId: orderId,
        assignedMechanic: _createOrUpdateOrder ? _selectedMechanic : null,
        priority: _createOrUpdateOrder ? _priority : null,
        mileageAtIntake: _createOrUpdateOrder
            ? int.tryParse(_mileageController.text.trim())
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;

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
              a.vehicleName,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${a.registrationNumber} · ${a.customerName} (${a.customerPhone})',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (a.status == ManagerAppointmentStatus.requested) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3DF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFB97819),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Wizyta oczekuje na zatwierdzenie. Możesz dostosować czas trwania przed potwierdzeniem.',
                        style: TextStyle(
                          color: Color(0xFF9A6A16),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _confirmAndSave(approveRequested: true),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB97819),
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Zatwierdź'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'STANOWISKO I CZAS WIZYTY',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _stationId,
              decoration: const InputDecoration(
                labelText: 'Stanowisko robocze',
                prefixIcon: Icon(Icons.home_repair_service_outlined),
              ),
              items: widget.stations
                  .map(
                    (st) =>
                        DropdownMenuItem(value: st.id, child: Text(st.name)),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _stationId = val);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: true),
                    icon: const Icon(Icons.schedule_rounded, size: 18),
                    label: Text('Od: ${_startTime.format(context)}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: false),
                    icon: const Icon(Icons.schedule_send_rounded, size: 18),
                    label: Text('Do: ${_endTime.format(context)}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ManagerAppointmentStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status wizyty',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ManagerAppointmentStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (status) {
                if (status != null) setState(() => _status = status);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Opis usterki / zakres prac',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppColors.teal,
                    title: Text(
                      a.orderId != null
                          ? 'Powiązane zlecenie: ${a.orderId}'
                          : 'Przyjmij pojazd i utwórz zlecenie serwisowe',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      a.orderId != null
                          ? 'Możesz zmienić przypisanego mechanika lub priorytet.'
                          : 'Zostanie utworzone zlecenie ${widget.suggestedOrderNumber}.',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    value: _createOrUpdateOrder,
                    onChanged: (val) =>
                        setState(() => _createOrUpdateOrder = val),
                  ),
                  if (_createOrUpdateOrder) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMechanic,
                      decoration: const InputDecoration(
                        labelText: 'Przydzielony mechanik',
                        prefixIcon: Icon(Icons.engineering_outlined),
                      ),
                      items: widget.mechanics
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedMechanic = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<OrderPriority>(
                            initialValue: _priority,
                            decoration: const InputDecoration(
                              labelText: 'Priorytet zlecenia',
                            ),
                            items: OrderPriority.values
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _priority = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _mileageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Przebieg (km)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _confirmAndSave,
                icon: const Icon(Icons.check_rounded),
                label: const Text(
                  'Zapisz zmiany',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
