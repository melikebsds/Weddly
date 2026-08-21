import 'package:dio/dio.dart';

/// Bölüm 29: Tüm API çağrıları için tek tip, kullanıcıya gösterilebilir hata.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return const ApiException('İnternet bağlantısı yok');
    }

    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException('Sunucuya ulaşılamadı, lütfen tekrar deneyin');
    }

    final statusCode = error.response?.statusCode;
    final serverMessage = _extractServerMessage(error.response?.data);

    switch (statusCode) {
      case 401:
        return ApiException(
          serverMessage ?? 'Oturum süresi dolmuş, lütfen tekrar giriş yapın',
          statusCode: statusCode,
        );
      case 403:
        return ApiException(
          serverMessage ?? 'Bu işlem için yetkiniz yok',
          statusCode: statusCode,
        );
      case 404:
        return ApiException(serverMessage ?? 'Kayıt bulunamadı', statusCode: statusCode);
      case 409:
        return ApiException(
          serverMessage ?? 'Bu işlem daha önce yapılmış',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          serverMessage ?? 'Sunucu hatası oluştu',
          statusCode: statusCode,
        );
    }
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  @override
  String toString() => message;
}
