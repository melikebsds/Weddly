import 'package:flutter/foundation.dart';

import '../core/errors/api_exception.dart';
import '../models/user.dart';
import '../services/auth_api_service.dart';
import '../services/secure_storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Bölüm 14-15: Kullanıcının giriş durumu ve oturum bilgisi.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthApiService authApiService,
    required SecureStorageService storage,
  })  : _authApiService = authApiService,
        _storage = storage;

  final AuthApiService _authApiService;
  final SecureStorageService _storage;

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;

  Future<void> tryAutoLogin() async {
    final token = await _storage.readToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      currentUser = await _authApiService.me();
      status = AuthStatus.authenticated;
    } catch (_) {
      await _storage.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authApiService.register(name: name, email: email, password: password);
    await _storage.saveToken(result.token);
    currentUser = result.user;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    final result = await _authApiService.login(email: email, password: password);
    await _storage.saveToken(result.token);
    currentUser = result.user;
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clear();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

/// Servis katmanından gelen ApiException'ı ekranda gösterilecek düz metne çevirir.
String describeError(Object error) {
  if (error is ApiException) return error.message;
  return 'Beklenmeyen bir hata oluştu';
}
