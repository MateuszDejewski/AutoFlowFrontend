enum ManagerAppointmentStatus { requested, scheduled, completed, cancelled }

enum OrderPriority { low, normal, high }

extension ManagerAppointmentStatusPresentation on ManagerAppointmentStatus {
  String get label => switch (this) {
    ManagerAppointmentStatus.requested => 'Oczekuje na potwierdzenie',
    ManagerAppointmentStatus.scheduled => 'Zaplanowana',
    ManagerAppointmentStatus.completed => 'Zakończona',
    ManagerAppointmentStatus.cancelled => 'Anulowana',
  };
}

extension OrderPriorityPresentation on OrderPriority {
  String get label => switch (this) {
    OrderPriority.low => 'Niski',
    OrderPriority.normal => 'Normalny',
    OrderPriority.high => 'Wysoki',
  };
}

class ManagerAppointment {
  const ManagerAppointment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleId,
    required this.vehicleName,
    required this.registrationNumber,
    required this.stationId,
    required this.status,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.orderId,
    this.assignedMechanic,
    this.priority,
    this.mileageAtIntake,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleId;
  final String vehicleName;
  final String registrationNumber;
  final String stationId;
  final String? orderId;
  final ManagerAppointmentStatus status;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? assignedMechanic;
  final OrderPriority? priority;
  final int? mileageAtIntake;

  ManagerAppointment copyWith({
    String? stationId,
    String? orderId,
    ManagerAppointmentStatus? status,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? assignedMechanic,
    OrderPriority? priority,
    int? mileageAtIntake,
  }) {
    return ManagerAppointment(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      registrationNumber: registrationNumber,
      stationId: stationId ?? this.stationId,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      assignedMechanic: assignedMechanic ?? this.assignedMechanic,
      priority: priority ?? this.priority,
      mileageAtIntake: mileageAtIntake ?? this.mileageAtIntake,
    );
  }
}
