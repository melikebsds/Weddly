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
    String? subCategory,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    ResponsibleParty responsibleParty = ResponsibleParty.unspecified,
    String? productUrl,
    DateTime? dueDate,
    WeddingTaskStatus status = WeddingTaskStatus.toBuy,
  }) async {
    final json = await _client.post('/categories/$categoryId/tasks', {
      'title': title,
      'subCategory': subCategory,
      'description': description,
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'responsibleParty': responsibleParty.value,
      'productUrl': productUrl,
      'dueDate': dueDate?.toIso8601String(),
      'status': status.value,
    });
    return WeddingTask.fromJson(json);
  }

  Future<WeddingTask> update(
    String taskId, {
    required String title,
    String? subCategory,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    required ResponsibleParty responsibleParty,
    String? productUrl,
    DateTime? dueDate,
    required WeddingTaskStatus status,
  }) async {
    final json = await _client.put('/tasks/$taskId', {
      'title': title,
      'subCategory': subCategory,
      'description': description,
      'estimatedPrice': estimatedPrice,
      'actualPrice': actualPrice,
      'responsibleParty': responsibleParty.value,
      'productUrl': productUrl,
      'dueDate': dueDate?.toIso8601String(),
      'status': status.value,
    });
    return WeddingTask.fromJson(json);
  }

  Future<void> delete(String taskId) => _client.delete('/tasks/$taskId');

  Future<WeddingTask> setStatus(String taskId, WeddingTaskStatus status) async {
    final json = await _client.patch('/tasks/$taskId/status', {'status': status.value});
    return WeddingTask.fromJson(json);
  }
}
