import '../../../../core/network/api_service.dart';
import '../models/company_model.dart';

class CompanyService {
  final ApiService _apiService;

  CompanyService(this._apiService);

  /// GET /companies - Fetch all marketing companies with optional pagination & query
  Future<List<CompanyModel>> getCompanies({
    int page = 1,
    int limit = 100,
    String q = '',
  }) async {
    final queryParams = '?page=$page&limit=$limit&q=${Uri.encodeComponent(q)}';
    final response = await _apiService.get('/companies$queryParams');

    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((item) => CompanyModel.fromJson(item))
          .toList();
    } else if (response is Map<String, dynamic>) {
      var data = response['data'] ?? response['companies'] ?? response['list'];
      if (data is Map<String, dynamic>) {
        data = data['items'] ?? data['companies'] ?? data['data'] ?? data['list'];
      }
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => CompanyModel.fromJson(item))
            .toList();
      }
    }
    return [];
  }

  /// GET /companies/{id} - Fetch single company by ID
  Future<CompanyModel> getCompanyById(int id) async {
    final response = await _apiService.get('/companies/$id');

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response['company'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(response['company'] as Map<String, dynamic>);
      }
      return CompanyModel.fromJson(response);
    }
    throw Exception('Failed to load company details');
  }

  /// POST /companies - Create marketing company
  Future<CompanyModel> createCompany(CompanyModel company) async {
    final response = await _apiService.post(
      '/companies',
      body: company.toJson(),
    );

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response['company'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(response['company'] as Map<String, dynamic>);
      }
      return CompanyModel.fromJson(response);
    }
    return company;
  }

  /// PUT /companies/{id} - Update marketing company
  Future<CompanyModel> updateCompany(int id, CompanyModel company) async {
    final response = await _apiService.put(
      '/companies/$id',
      body: company.toJson(),
    );

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(response['data'] as Map<String, dynamic>);
      } else if (response['company'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(response['company'] as Map<String, dynamic>);
      }
      return CompanyModel.fromJson(response);
    }
    return company;
  }

  /// DELETE /companies/{id} - Delete marketing company
  Future<bool> deleteCompany(int id) async {
    final response = await _apiService.delete('/companies/$id');
    if (response is Map<String, dynamic>) {
      return response['success'] == true || response['status'] == 'success';
    }
    return true;
  }
}
