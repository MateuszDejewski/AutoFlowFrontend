class InspectionReminder {
  const InspectionReminder({
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.inspectionDate,
  });

  final String vehicleId;
  final String title;
  final String description;
  final DateTime inspectionDate;
}
