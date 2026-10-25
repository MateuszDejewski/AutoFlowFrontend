class Appointment {
  const Appointment({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.description,
  });

  final String id;
  final String vehicleId;
  final DateTime date;
  final String description;
}
