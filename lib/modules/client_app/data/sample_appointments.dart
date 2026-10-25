import '../models/appointment.dart';

final sampleAppointments = [
  Appointment(
    id: 'appointment-001',
    vehicleId: 'vehicle-volvo-xc60',
    date: DateTime(2026, 11, 2, 9),
    description: 'Przegląd okresowy',
  ),
  Appointment(
    id: 'appointment-002',
    vehicleId: 'vehicle-toyota-corolla',
    date: DateTime(2026, 11, 6, 11, 30),
    description: 'Wymiana oleju i filtrów',
  ),
];
