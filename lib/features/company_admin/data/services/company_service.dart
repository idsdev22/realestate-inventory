import '../../../../core/network/api_service.dart';
import '../models/company_model.dart';

class CompanyService {
  final ApiService _apiService;

  CompanyService(this._apiService);

  /// GET /companies - Fetch all marketing companies
  Future<List<CompanyModel>> getCompanies() async {
    final response = await _apiService.get('/companies');

    if (response is Map<String, dynamic>) {
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response['companies'] is List) {
        return (response['companies'] as List)
            .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } else if (response is List) {
      return response
          .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
          .toList();
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
