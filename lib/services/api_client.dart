import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/errors/api_exception.dart';
import 'secure_storage_service.dart';

/// Bölüm 28: Flutter ile backend arasındaki tüm REST iletişimi bu istemci
/// üzerinden yapılır. Her istekte Authorization: Bearer {token} eklenir.
class ApiClient {
  ApiClient({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService(),
        _dio = Dio(BaseOptions(
          baseUrl: apiBaseUrl,
          // Render'ın ücretsiz katmanı hareketsizlikte uyur; ilk istek
          // sunucuyu uyandırırken 50 saniyeye kadar sürebilir.
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.readToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  final Dio _dio;
  final SecureStorageService _storage;

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _run(() => _dio.get(path));
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _run(() => _dio.get(path));
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    final response = await _run(() => _dio.post(path, data: body ?? const {}));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final response = await _run(() => _dio.put(path, data: body));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patch(String path, [Map<String, dynamic>? body]) async {
    final response = await _run(() => _dio.patch(path, data: body ?? const {}));
    return response.data as Map<String, dynamic>;
  }

  Future<void> delete(String path) async {
    await _run(() => _dio.delete(path));
  }

  Future<Response> _run(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
