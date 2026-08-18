import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response is Map<String, dynamic>) {
      return AuthResponseModel.fromJson(response);
    }
    return AuthResponseModel(
      success: false,
      message: 'Unexpected response from server',
    );
  }

  Future<bool> forgotPassword({required String email}) async {
    final response = await _apiService.post(
      ApiConstants.forgotPassword,
      body: {
        'email': email,
      },
    );

    if (response is Map<String, dynamic>) {
      return response['success'] == true;
    }
    return false;
  }

  Future<UserModel?> getMe() async {
    final response = await _apiService.get(ApiConstants.me);

    if (response is Map<String, dynamic> && response['success'] == true) {
      if (response['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<bool> logout() async {
    try {
      final response = await _apiService.post(ApiConstants.logout);
      if (response is Map<String, dynamic>) {
        return response['success'] == true;
      }
      return true;
    } catch (_) {
      // Even if network fails on logout, allow local session cleanup
      return true;
    }
  }
}
