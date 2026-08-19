import '../../../../core/network/api_service.dart';
import '../models/activity_log_model.dart';

class ActivityService {
  final ApiService _apiService;

  ActivityService({required ApiService apiService}) : _apiService = apiService;

  Future<List<ActivityLogModel>> getActivities({
    int page = 1,
    int limit = 1000,
    String q = '',
  }) async {
    try {
      final queryParams = '?page=$page&limit=$limit&q=$q';
      final response = await _apiService.get('/activity$queryParams');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        List<dynamic> activitiesList = [];
        if (data is Map<String, dynamic>) {
          if (data['items'] != null) {
            activitiesList = data['items'];
          } else if (data['data'] != null) {
            activitiesList = data['data'];
          }
        } else if (data is List) {
          activitiesList = data;
        }

        return activitiesList
            .map((json) => ActivityLogModel.fromJson(json))
            .toList();
      } else if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ActivityLogModel.fromJson(json))
            .toList();
      } else if (response is Map<String, dynamic> &&
          response['data'] != null &&
          response['data'] is Map<String, dynamic> &&
          response['data']['data'] is List) {
        return (response['data']['data'] as List)
            .map((json) => ActivityLogModel.fromJson(json))
            .toList();
      } else if (response is List) {
        return response.map((json) => ActivityLogModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
