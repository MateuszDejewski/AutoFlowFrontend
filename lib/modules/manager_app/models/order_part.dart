class OrderPart {
  const OrderPart({
    required this.id,
    required this.orderId,
    required this.vehicleLabel,
    required this.partId,
    required this.partName,
    required this.partNumber,
    required this.quantity,
    required this.unitPrice,
  });

  final String id;
  final String orderId;
  final String vehicleLabel;
  final String partId;
  final String partName;
  final String partNumber;
  final int quantity;
  final double unitPrice;

  double get totalCost => quantity * unitPrice;
}
