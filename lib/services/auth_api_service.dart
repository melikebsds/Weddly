import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  final String token;
  final AppUser user;

  const AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class AuthApiService {
  AuthApiService(this._client);

  final ApiClient _client;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _client.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return AuthResult.fromJson(json);
  }

  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _client.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthResult.fromJson(json);
  }

  Future<AppUser> me() async {
    final json = await _client.get('/auth/me');
    return AppUser.fromJson(json);
  }
}
