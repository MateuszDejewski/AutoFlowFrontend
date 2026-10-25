import '../models/vehicle.dart';

final sampleVehicles = [
  Vehicle(
    id: 'vehicle-volvo-xc60',
    brand: 'Volvo',
    model: 'XC60',
    productionYear: 2021,
    vin: 'YV1UZBFV8M1234567',
    registrationNumber: 'WI 7K284',
    mileage: 68420,
    nextInspectionDate: DateTime(2026, 11, 2),
  ),
  const Vehicle(
    id: 'vehicle-toyota-corolla',
    brand: 'Toyota',
    model: 'Corolla',
    productionYear: 2019,
    vin: 'JTDBR32E102345678',
    registrationNumber: 'KR 4M912',
    mileage: 91250,
  ),
];
