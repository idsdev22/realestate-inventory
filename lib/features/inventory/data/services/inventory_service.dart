import 'package:realestate_inventory/core/network/api_service.dart';
import 'package:realestate_inventory/features/inventory/data/models/unit_model.dart';

class InventoryService {
  final ApiService _apiService;

  InventoryService(this._apiService);

  Future<List<UnitModel>> getInventory({String? status}) async {
    final queryParams = status != null && status != 'All' ? '?status=${status.toLowerCase()}' : '';
    final response = await _apiService.get('/inventory$queryParams');

    if (response != null && response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => UnitModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<UnitModel?> getUnitById(int id) async {
    final response = await _apiService.get('/inventory/$id');
    if (response != null && response['success'] == true && response['data'] != null) {
      return UnitModel.fromJson(response['data']);
    }
    return null;
  }

  Future<UnitModel?> createUnit(UnitModel unit) async {
    final response = await _apiService.post('/inventory', body: unit.toJson());
    if (response != null && response['success'] == true && response['data'] != null) {
      return UnitModel.fromJson(response['data']);
    }
    return null;
  }

  Future<UnitModel?> updateUnit(int id, UnitModel unit) async {
    final response = await _apiService.put('/inventory/$id', body: unit.toJson());
    if (response != null && response['success'] == true && response['data'] != null) {
      return UnitModel.fromJson(response['data']);
    }
    return null;
  }

  Future<bool> deleteUnit(int id) async {
    final response = await _apiService.delete('/inventory/$id');
    if (response != null && response['success'] == true) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getInventoryStats() async {
    final response = await _apiService.get('/inventory/stats');
    if (response != null && response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
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
