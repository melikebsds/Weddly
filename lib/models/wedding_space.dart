class WeddingSpace {
  final String id;
  final String name;
  final DateTime? weddingDate;
  final DateTime createdAt;
  final String createdByUserId;

  const WeddingSpace({
    required this.id,
    required this.name,
    required this.weddingDate,
    required this.createdAt,
    required this.createdByUserId,
  });

  factory WeddingSpace.fromJson(Map<String, dynamic> json) => WeddingSpace(
        id: json['id'] as String,
        name: json['name'] as String,
        weddingDate:
            json['weddingDate'] == null ? null : DateTime.parse(json['weddingDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        createdByUserId: json['createdByUserId'] as String,
      );
}
