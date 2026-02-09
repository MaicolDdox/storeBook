import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<UserModel> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password, 'device_name': deviceName},
    );

    final payload = response.data['data'] as Map<String, dynamic>;
    final token = payload['token'] as String;
    await _tokenStorage.saveToken(token);

    return UserModel.fromJson(payload['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'device_name': deviceName,
      },
    );

    final payload = response.data['data'] as Map<String, dynamic>;
    final token = payload['token'] as String;
    await _tokenStorage.saveToken(token);

    return UserModel.fromJson(payload['user'] as Map<String, dynamic>);
  }

  Future<UserModel> me() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout', data: {});
    } finally {
      await _tokenStorage.deleteToken();
    }
  }

  Future<String?> readToken() => _tokenStorage.readToken();
}
