class Vehicle {
  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.productionYear,
    required this.vin,
    required this.registrationNumber,
    this.mileage,
    this.nextInspectionDate,
  });

  final String id;
  final String brand;
  final String model;
  final int productionYear;
  final String vin;
  final String registrationNumber;
  final int? mileage;
  final DateTime? nextInspectionDate;
}
