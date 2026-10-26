class Part {
  const Part({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.stockQuantity,
    required this.unitPrice,
  });

  final String id;
  final String name;
  final String partNumber;
  final int stockQuantity;
  final double unitPrice;

  Part copyWith({
    String? name,
    String? partNumber,
    int? stockQuantity,
    double? unitPrice,
  }) {
    return Part(
      id: id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
