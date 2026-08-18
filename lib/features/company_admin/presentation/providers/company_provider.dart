import 'package:flutter/foundation.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/company_model.dart';
import '../../data/services/company_service.dart';

class CompanyProvider extends ChangeNotifier {
  final CompanyService _companyService;

  List<CompanyModel> _companies = [];
  CompanyModel? _selectedCompany;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'inactive'

  CompanyProvider(this._companyService);

  List<CompanyModel> get companies => _companies;
  CompanyModel? get selectedCompany => _selectedCompany;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  int get totalCompanies => _companies.length;
  int get activeCompaniesCount => _companies.where((c) => c.isActive).length;
  int get inactiveCompaniesCount => _companies.where((c) => !c.isActive).length;

  List<CompanyModel> get filteredCompanies {
    return _companies.where((company) {
      final matchesSearch = _searchQuery.isEmpty ||
          company.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          company.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          company.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          company.phone.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'active' && company.isActive) ||
          (_statusFilter == 'inactive' && !company.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// GET /companies
  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _companyService.getCompanies();
      _companies = list;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load marketing companies. Please try again.';
      debugPrint('Error fetching companies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GET /companies/{id}
  Future<CompanyModel?> fetchCompanyById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final company = await _companyService.getCompanyById(id);
      _selectedCompany = company;
      return company;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to load company details.';
      debugPrint('Error fetching company $id: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// POST /companies
  Future<bool> createCompany(CompanyModel company) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _companyService.createCompany(company);
      _companies = [created, ..._companies];
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create marketing company.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// PUT /companies/{id}
  Future<bool> updateCompany(int id, CompanyModel company) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _companyService.updateCompany(id, company);
      final index = _companies.indexWhere((c) => c.id == id);
      if (index != -1) {
        _companies[index] = updated;
      } else {
        _companies = _companies.map((c) => c.id == id ? updated : c).toList();
      }
      if (_selectedCompany?.id == id) {
        _selectedCompany = updated;
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update marketing company.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// DELETE /companies/{id}
  Future<bool> deleteCompany(int id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _companyService.deleteCompany(id);
      if (success) {
        _companies.removeWhere((c) => c.id == id);
        if (_selectedCompany?.id == id) {
          _selectedCompany = null;
        }
      }
      _isSubmitting = false;
      notifyListeners();
      return success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete marketing company.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
