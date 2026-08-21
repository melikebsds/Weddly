import '../models/wedding_space.dart';
import 'api_client.dart';

class WeddingSpaceApiService {
  WeddingSpaceApiService(this._client);

  final ApiClient _client;

  Future<WeddingSpace> create({required String name, DateTime? weddingDate}) async {
    final json = await _client.post('/wedding-spaces', {
      'name': name,
      'weddingDate': weddingDate?.toIso8601String(),
    });
    return WeddingSpace.fromJson(json);
  }

  Future<List<WeddingSpace>> getAll() async {
    final json = await _client.getList('/wedding-spaces');
    return json.map((e) => WeddingSpace.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WeddingSpace> getById(String id) async {
    final json = await _client.get('/wedding-spaces/$id');
    return WeddingSpace.fromJson(json);
  }

  Future<WeddingSpace> update(String id, {required String name, DateTime? weddingDate}) async {
    final json = await _client.put('/wedding-spaces/$id', {
      'name': name,
      'weddingDate': weddingDate?.toIso8601String(),
    });
    return WeddingSpace.fromJson(json);
  }
}
