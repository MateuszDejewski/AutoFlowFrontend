import '../models/service_order.dart';

final sampleServiceOrders = [
  ServiceOrder(
    id: 'SO-2026-1013',
    vehicleId: 'vehicle-volvo-xc60',
    status: ServiceOrderStatus.ready,
    description: 'Wymiana filtra kabinowego',
    deadline: DateTime(2026, 10, 20),
    createdAt: DateTime(2026, 10, 18, 11, 20),
    completedAt: DateTime(2026, 10, 19, 15, 40),
  ),
  ServiceOrder(
    id: 'SO-2026-1042',
    vehicleId: 'vehicle-volvo-xc60',
    status: ServiceOrderStatus.inProgress,
    description: 'Przegląd okresowy i wymiana oleju',
    deadline: DateTime(2026, 10, 28),
    createdAt: DateTime(2026, 10, 24, 9, 30),
  ),
  ServiceOrder(
    id: 'SO-2026-1048',
    vehicleId: 'vehicle-toyota-corolla',
    status: ServiceOrderStatus.received,
    description: 'Kontrola pracy silnika',
    deadline: DateTime(2026, 10, 29),
    createdAt: DateTime(2026, 10, 25, 10, 5),
  ),
  ServiceOrder(
    id: 'SO-2026-1037',
    vehicleId: 'vehicle-toyota-corolla',
    status: ServiceOrderStatus.waitingForParts,
    description: 'Diagnostyka układu hamulcowego',
    deadline: DateTime(2026, 10, 30),
    createdAt: DateTime(2026, 10, 22, 14, 15),
  ),
  ServiceOrder(
    id: 'SO-2026-0981',
    vehicleId: 'vehicle-volvo-xc60',
    status: ServiceOrderStatus.pickedUp,
    description: 'Wymiana klocków hamulcowych',
    createdAt: DateTime(2026, 10, 10, 8, 45),
    completedAt: DateTime(2026, 10, 11, 16, 20),
  ),
];
