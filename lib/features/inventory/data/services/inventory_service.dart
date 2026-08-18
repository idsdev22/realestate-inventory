import 'package:realestate_inventory/core/network/api_service.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';

class InventoryService {
  final ApiService _apiService;

  InventoryService(this._apiService);

  Future<List<UnitModel>> getInventory({String? status}) async {
    final queryParams = status != null && status != 'All' ? '?status=${status.toLowerCase()}' : '';
    final response = await _apiService.get('/inventory$queryParams');

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((json) => UnitModel.fromJson(json))
          .toList();
    }
    if (response is Map<String, dynamic>) {
      var data = response['data'] ?? response['units'] ?? response['inventory'] ?? response['list'];
      if (data is Map<String, dynamic>) {
        data = data['items'] ?? data['units'] ?? data['inventory'] ?? data['plots'] ?? data['data'] ?? data['list'];
      }
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => UnitModel.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<UnitModel?> getUnitById(int id) async {
    final response = await _apiService.get('/inventory/$id');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['unit'] ?? response;
      if (data is Map<String, dynamic>) {
        return UnitModel.fromJson(data);
      }
    }
    return null;
  }

  Future<UnitModel?> createUnit(UnitModel unit) async {
    final response = await _apiService.post('/inventory', body: unit.toJson());
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['unit'] ?? response;
      if (data is Map<String, dynamic>) {
        return UnitModel.fromJson(data);
      }
    }
    return null;
  }

  Future<UnitModel?> updateUnit(int id, UnitModel unit) async {
    final response = await _apiService.put('/inventory/$id', body: unit.toJson());
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['unit'] ?? response;
      if (data is Map<String, dynamic>) {
        return UnitModel.fromJson(data);
      }
    }
    return null;
  }

  Future<bool> deleteUnit(int id) async {
    final response = await _apiService.delete('/inventory/$id');
    if (response is Map<String, dynamic>) {
      return response['success'] == true || response['status'] == 'success';
    }
    return response != null;
  }

  Future<Map<String, dynamic>> getInventoryStats() async {
    final response = await _apiService.get('/inventory/stats');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return {};
  }

  Future<bool> bulkUpdateStatus(List<int> ids, String action, String status, {String? remarks}) async {
    final response = await _apiService.post('/inventory/bulk', body: {
      'ids': ids,
      'action': action,
      'status': status.toLowerCase(),
      'remarks': ?remarks,
    });
    
    if (response != null && response['success'] == true) {
      return true;
    }
    return false;
  }
}
