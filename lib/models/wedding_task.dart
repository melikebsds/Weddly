/// Backend'deki WeddingTaskStatus enum'ıyla birebir eşleşir (0/1/2).
enum WeddingTaskStatus {
  toBuy,
  bought,
  notNeeded;

  static WeddingTaskStatus fromValue(int value) => WeddingTaskStatus.values[value];

  int get value => index;

  String get label => switch (this) {
        WeddingTaskStatus.toBuy => 'Alınacak',
        WeddingTaskStatus.bought => 'Alındı',
        WeddingTaskStatus.notNeeded => 'İhtiyaç Yok',
      };
}

class WeddingTask {
  final String id;
  final String weddingSpaceId;
  final String categoryId;
  final String title;
  final String? subCategory;
  final String? description;
  final double? estimatedPrice;
  final double? actualPrice;
  final String? assignedUserId;
  final WeddingTaskStatus status;

  const WeddingTask({
    required this.id,
    required this.weddingSpaceId,
    required this.categoryId,
    required this.title,
    this.subCategory,
    this.description,
    this.estimatedPrice,
    this.actualPrice,
    this.assignedUserId,
    this.status = WeddingTaskStatus.toBuy,
  });

  factory WeddingTask.fromJson(Map<String, dynamic> json) => WeddingTask(
        id: json['id'] as String,
        weddingSpaceId: json['weddingSpaceId'] as String,
        categoryId: json['categoryId'] as String,
        title: json['title'] as String,
        subCategory: json['subCategory'] as String?,
        description: json['description'] as String?,
        estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
        actualPrice: (json['actualPrice'] as num?)?.toDouble(),
        assignedUserId: json['assignedUserId'] as String?,
        status: WeddingTaskStatus.fromValue(json['status'] as int? ?? 0),
      );
}
