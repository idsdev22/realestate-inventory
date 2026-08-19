import '../../../../core/network/api_service.dart';
import '../models/block_request_model.dart';

class RequestService {
  final ApiService _apiService;

  RequestService({required ApiService apiService}) : _apiService = apiService;

  Future<List<BlockRequestModel>> getRequests({
    String status = '',
    int page = 1,
    int limit = 1000,
  }) async {
    try {
      final response = await _apiService.get(
        '/requests?status=$status&page=$page&limit=$limit',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        List<dynamic> requestsList = [];
        if (data is Map<String, dynamic>) {
          if (data['items'] != null) {
            requestsList = data['items'];
          } else if (data['data'] != null) {
            requestsList = data['data'];
          }
        } else if (data is List) {
          requestsList = data;
        }

        return requestsList
            .map((json) => BlockRequestModel.fromJson(json))
            .toList();
      } else if (response is Map<String, dynamic> && response['data'] is List) {
        // Fallback if success isn't strictly true but data is a list
        return (response['data'] as List)
            .map((json) => BlockRequestModel.fromJson(json))
            .toList();
      } else if (response is Map<String, dynamic> &&
          response['data'] != null &&
          response['data'] is Map<String, dynamic> &&
          response['data']['data'] is List) {
        return (response['data']['data'] as List)
            .map((json) => BlockRequestModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<BlockRequestModel> createRequest(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/requests', body: data);
      final responseData = response['data'] ?? response;
      return BlockRequestModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<BlockRequestModel> updateRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put('/requests/$id', body: data);
      final responseData = response['data'] ?? response;
      return BlockRequestModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRequest(String id) async {
    try {
      await _apiService.delete('/requests/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<BlockRequestModel> reviewRequest({
    required String id,
    required String decision,
    String? reviewNotes,
  }) async {
    try {
      final body = {
        'decision': decision,
        if (reviewNotes != null && reviewNotes.isNotEmpty)
          'review_notes': reviewNotes,
      };
      final response = await _apiService.post(
        '/requests/$id/review',
        body: body,
      );
      final responseData = response['data'] ?? response;
      return BlockRequestModel.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }
}
