import '../models/mechanic_task.dart';

List<MechanicTask> sampleMechanicTasksFor(DateTime day) {
  DateTime at(int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  return [
    MechanicTask(
      orderNumber: 'SO-2026-1051',
      customerName: 'Anna Kowalska',
      vehicleName: 'Toyota Corolla · 2020',
      registrationNumber: 'WA 4K812',
      stationName: 'Stanowisko 1',
      description: 'Diagnostyka układu hamulcowego i wymiana klocków.',
      priority: MechanicTaskPriority.high,
      mileageAtIntake: 84620,
      deadline: day.add(const Duration(days: 1)),
      startTime: at(8, 0),
      endTime: at(10, 0),
      status: MechanicTaskStatus.inProgress,
    ),
    MechanicTask(
      orderNumber: 'SO-2026-1054',
      customerName: 'Piotr Nowak',
      vehicleName: 'Volvo XC60 · 2019',
      registrationNumber: 'KR 8M204',
      stationName: 'Podnośnik 2',
      description: 'Przegląd okresowy, wymiana oleju i filtrów.',
      priority: MechanicTaskPriority.normal,
      mileageAtIntake: 112400,
      deadline: day.add(const Duration(days: 2)),
      startTime: at(10, 30),
      endTime: at(12, 30),
      status: MechanicTaskStatus.received,
    ),
    MechanicTask(
      orderNumber: 'SO-2026-1058',
      customerName: 'Marta Wiśniewska',
      vehicleName: 'Skoda Octavia · 2018',
      registrationNumber: 'PO 2A650',
      stationName: 'Stanowisko 3',
      description: 'Wymiana przedniego łożyska koła.',
      priority: MechanicTaskPriority.low,
      mileageAtIntake: 97350,
      deadline: day.add(const Duration(days: 3)),
      startTime: at(13, 0),
      endTime: at(15, 30),
      status: MechanicTaskStatus.waitingForParts,
    ),
  ];
}
