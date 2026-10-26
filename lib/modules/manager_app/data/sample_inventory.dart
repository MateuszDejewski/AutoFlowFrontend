import '../models/order_part.dart';
import '../models/part.dart';

const List<Part> sampleParts = [
  Part(
    id: 'part-1',
    name: 'Klocki hamulcowe przód (komplet)',
    partNumber: 'TRW-GDB1956',
    stockQuantity: 14,
    unitPrice: 215.00,
  ),
  Part(
    id: 'part-2',
    name: 'Olej silnikowy 5W-30 Syntetyk (5L)',
    partNumber: 'MOT-8100-5L',
    stockQuantity: 22,
    unitPrice: 189.00,
  ),
  Part(
    id: 'part-3',
    name: 'Filtr oleju',
    partNumber: 'MANN-W712/95',
    stockQuantity: 31,
    unitPrice: 42.50,
  ),
  Part(
    id: 'part-4',
    name: 'Łożysko koła przedniego z piastą',
    partNumber: 'SKF-VKBA6556',
    stockQuantity: 4,
    unitPrice: 360.00,
  ),
  Part(
    id: 'part-5',
    name: 'Akumulator 12V 74Ah 680A',
    partNumber: 'BOS-S4-008',
    stockQuantity: 6,
    unitPrice: 440.00,
  ),
];

const List<OrderPart> sampleOrderParts = [
  OrderPart(
    id: 'op-1',
    orderId: 'SO-2026-1051',
    vehicleLabel: 'Toyota Corolla · WA 4K812',
    partId: 'part-1',
    partName: 'Klocki hamulcowe przód (komplet)',
    partNumber: 'TRW-GDB1956',
    quantity: 1,
    unitPrice: 215.00,
  ),
  OrderPart(
    id: 'op-2',
    orderId: 'SO-2026-1054',
    vehicleLabel: 'Volvo XC60 · KR 8M204',
    partId: 'part-2',
    partName: 'Olej silnikowy 5W-30 Syntetyk (5L)',
    partNumber: 'MOT-8100-5L',
    quantity: 1,
    unitPrice: 189.00,
  ),
  OrderPart(
    id: 'op-3',
    orderId: 'SO-2026-1054',
    vehicleLabel: 'Volvo XC60 · KR 8M204',
    partId: 'part-3',
    partName: 'Filtr oleju',
    partNumber: 'MANN-W712/95',
    quantity: 1,
    unitPrice: 42.50,
  ),
  OrderPart(
    id: 'op-4',
    orderId: 'SO-2026-1044',
    vehicleLabel: 'Audi A4 · GD 3L992',
    partId: 'part-5',
    partName: 'Akumulator 12V 74Ah 680A',
    partNumber: 'BOS-S4-008',
    quantity: 1,
    unitPrice: 435.00,
  ),
];

const List<(String, String)> sampleActiveServiceOrders = [
  ('SO-2026-1051', 'Toyota Corolla · WA 4K812'),
  ('SO-2026-1054', 'Volvo XC60 · KR 8M204'),
  ('SO-2026-1058', 'Skoda Octavia · PO 2A650'),
];
