import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Bölüm 27: JWT Token ve aktif WeddingSpace Id güvenli şekilde saklanır.
class SecureStorageService {
  static const _tokenKey = 'bridely.jwt_token';
  static const _activeWeddingSpaceIdKey = 'bridely.active_wedding_space_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> readActiveWeddingSpaceId() => _storage.read(key: _activeWeddingSpaceIdKey);

  Future<void> saveActiveWeddingSpaceId(String id) =>
      _storage.write(key: _activeWeddingSpaceIdKey, value: id);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _activeWeddingSpaceIdKey);
  }
}
