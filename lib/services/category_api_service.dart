import '../models/category.dart';
import 'api_client.dart';

class CategoryApiService {
  CategoryApiService(this._client);

  final ApiClient _client;

  Future<List<WeddingCategory>> getForSpace(String weddingSpaceId) async {
    final json = await _client.getList('/wedding-spaces/$weddingSpaceId/categories');
    return json.map((e) => WeddingCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WeddingCategory> create(
    String weddingSpaceId, {
    required String name,
    String? description,
    int order = 0,
  }) async {
    final json = await _client.post('/wedding-spaces/$weddingSpaceId/categories', {
      'name': name,
      'description': description,
      'order': order,
    });
    return WeddingCategory.fromJson(json);
  }

  Future<WeddingCategory> update(
    String categoryId, {
    required String name,
    String? description,
    required int order,
  }) async {
    final json = await _client.put('/categories/$categoryId', {
      'name': name,
      'description': description,
      'order': order,
    });
    return WeddingCategory.fromJson(json);
  }

  Future<void> delete(String categoryId) => _client.delete('/categories/$categoryId');
}
