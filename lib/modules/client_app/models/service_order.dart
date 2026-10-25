enum ServiceOrderStatus {
  received,
  inProgress,
  waitingForParts,
  ready,
  pickedUp,
}

class ServiceOrder {
  const ServiceOrder({
    required this.id,
    required this.vehicleId,
    required this.status,
    required this.description,
    required this.createdAt,
    this.deadline,
    this.completedAt,
  });

  final String id;
  final String vehicleId;
  final ServiceOrderStatus status;
  final String description;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime? completedAt;
}
