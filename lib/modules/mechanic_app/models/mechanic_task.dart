enum MechanicTaskStatus { received, inProgress, waitingForParts, ready }

extension MechanicTaskStatusPresentation on MechanicTaskStatus {
  String get label => switch (this) {
    MechanicTaskStatus.received => 'Przyjęte',
    MechanicTaskStatus.inProgress => 'W trakcie',
    MechanicTaskStatus.waitingForParts => 'Oczekuje na części',
    MechanicTaskStatus.ready => 'Gotowe do odbioru',
  };
}

class MechanicTask {
  const MechanicTask({
    required this.orderNumber,
    required this.customerName,
    required this.vehicleName,
    required this.registrationNumber,
    required this.stationName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.completionNote = '',
  });

  final String orderNumber;
  final String customerName;
  final String vehicleName;
  final String registrationNumber;
  final String stationName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final MechanicTaskStatus status;
  final String completionNote;

  MechanicTask copyWith({MechanicTaskStatus? status, String? completionNote}) {
    return MechanicTask(
      orderNumber: orderNumber,
      customerName: customerName,
      vehicleName: vehicleName,
      registrationNumber: registrationNumber,
      stationName: stationName,
      description: description,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      completionNote: completionNote ?? this.completionNote,
    );
  }
}
