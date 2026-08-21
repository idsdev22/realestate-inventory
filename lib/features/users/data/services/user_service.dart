import '../../../../core/network/api_service.dart';
import '../../../auth/data/models/user_model.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  /// GET /users - Fetch all users with optional search/filters/pagination
  Future<List<UserModel>> getUsers({
    int page = 1,
    int limit = 100,
    String q = '',
    String? role,
    String? status,
    int? companyId,
  }) async {
    final queryParams = StringBuffer('?page=$page&limit=$limit');
    if (q.trim().isNotEmpty) {
      queryParams.write('&q=${Uri.encodeComponent(q.trim())}');
    }
    if (role != null && role.isNotEmpty && role != 'all') {
      queryParams.write('&role=${Uri.encodeComponent(role)}');
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams.write('&status=${Uri.encodeComponent(status)}');
    }
    if (companyId != null) {
      queryParams.write('&company_id=$companyId');
    }

    final response = await _apiService.get('/users$queryParams');

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((item) => UserModel.fromJson(item))
          .toList();
    } else if (response is Map<String, dynamic>) {
      var data = response['data'] ?? response['users'] ?? response['list'];
      if (data is Map<String, dynamic>) {
        data = data['items'] ?? data['users'] ?? data['data'] ?? data['list'];
      }
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => UserModel.fromJson(item))
            .toList();
      }
    }
    return [];
  }

  /// GET /users/{id} - Fetch user by ID
  Future<UserModel> getUserById(int id) async {
    final response = await _apiService.get('/users/$id');

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['user'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(response);
    }
    throw Exception('Failed to load user details');
  }

  /// POST /users - Create user with payload
  /// Example payload:
  /// {
  ///   "name": "Sales Exec",
  ///   "email": "exec@abc.test",
  ///   "password": "TeamUser@123",
  ///   "role": "marketing_team_user",
  ///   "company_id": 1,
  ///   "project_ids": [1]
  /// }
  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    final body = Map<String, dynamic>.from(payload);
    final response = await _apiService.post(
      '/users',
      body: body,
    );

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['user'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(response);
    }
    return UserModel.fromJson(payload);
  }

  /// PUT /users/{id} - Update user
  Future<UserModel> updateUser(int id, Map<String, dynamic> payload) async {
    final response = await _apiService.put(
      '/users/$id',
      body: payload,
    );

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(response['user'] as Map<String, dynamic>);
      }
      return UserModel.fromJson(response);
    }
    return UserModel.fromJson(payload);
  }

  /// DELETE /users/{id} - Delete user
  Future<bool> deleteUser(int id) async {
    final response = await _apiService.delete('/users/$id');
    if (response is Map<String, dynamic>) {
      return response['success'] == true || response['status'] == 'success';
    }
    return true;
  }
}
