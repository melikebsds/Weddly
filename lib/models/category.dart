/// Bölüm 17: Kategori adına göre gösterilecek emoji. API bu bilgiyi
/// döndürmez (bölüm 36.5: API modelleri ve UI modelleri ayrılmalıdır),
/// bu yüzden istemci tarafında adla eşlenir.
const Map<String, String> _categoryIcons = {
  'Çeyiz': '🏠',
  'Ev İhtiyaçları': '🏡',
  'Kız İsteme': '💍',
  'Söz': '💍',
  'Nişan': '💍',
  'Bohça': '🎁',
  'Kına': '🔥',
  'Düğün': '👰',
  'Balayı': '✈️',
  'Resmi İşlemler': '📄',
};

const String _defaultCategoryIcon = '📌';

class WeddingCategory {
  final String id;
  final String weddingSpaceId;
  final String name;
  final String? description;
  final int order;
  final int totalTaskCount;
  final int completedTaskCount;

  const WeddingCategory({
    required this.id,
    required this.weddingSpaceId,
    required this.name,
    this.description,
    required this.order,
    this.totalTaskCount = 0,
    this.completedTaskCount = 0,
  });

  String get icon => _categoryIcons[name] ?? _defaultCategoryIcon;

  factory WeddingCategory.fromJson(Map<String, dynamic> json) => WeddingCategory(
        id: json['id'] as String,
        weddingSpaceId: json['weddingSpaceId'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        order: json['order'] as int,
        totalTaskCount: json['totalTaskCount'] as int? ?? 0,
        completedTaskCount: json['completedTaskCount'] as int? ?? 0,
      );
}
