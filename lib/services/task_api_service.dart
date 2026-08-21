import '../models/wedding_task.dart';
import 'api_client.dart';

class TaskApiService {
  TaskApiService(this._client);

  final ApiClient _client;

  Future<List<WeddingTask>> getForCategory(String categoryId) async {
    final json = await _client.getList('/categories/$categoryId/tasks');
    return json.map((e) => WeddingTask.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WeddingTask> create(
    String categoryId, {
    required String title,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    bool isCompleted = false,
  }) async {
    final json = await _client.post('/categories/$categoryId/tasks', {
      'title': title,
      'description': description,
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'isCompleted': isCompleted,
    });
    return WeddingTask.fromJson(json);
  }

  Future<WeddingTask> update(
    String taskId, {
    required String title,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    required bool isCompleted,
  }) async {
    final json = await _client.put('/tasks/$taskId', {
      'title': title,
      'description': description,
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'isCompleted': isCompleted,
    });
    return WeddingTask.fromJson(json);
  }

  Future<void> delete(String taskId) => _client.delete('/tasks/$taskId');

  Future<WeddingTask> setCompleted(String taskId, bool isCompleted) async {
    final json = await _client.patch('/tasks/$taskId/complete', {'isCompleted': isCompleted});
    return WeddingTask.fromJson(json);
  }
}
