class WeddingTask {
  final String id;
  final String weddingSpaceId;
  final String categoryId;
  final String title;
  final String? description;
  final double? estimatedPrice;
  final double? actualPrice;
  final String? assignedUserId;
  final bool isCompleted;

  const WeddingTask({
    required this.id,
    required this.weddingSpaceId,
    required this.categoryId,
    required this.title,
    this.description,
    this.estimatedPrice,
    this.actualPrice,
    this.assignedUserId,
    this.isCompleted = false,
  });

  factory WeddingTask.fromJson(Map<String, dynamic> json) => WeddingTask(
        id: json['id'] as String,
        weddingSpaceId: json['weddingSpaceId'] as String,
        categoryId: json['categoryId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
        actualPrice: (json['actualPrice'] as num?)?.toDouble(),
        assignedUserId: json['assignedUserId'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}
