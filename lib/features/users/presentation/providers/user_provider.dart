import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;

  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _limit = 50;

  String _searchQuery = '';
  String _roleFilter = 'all'; // 'all', 'promoter_admin', 'marketing_team_admin', 'marketing_team_user'
  String _statusFilter = 'all'; // 'all', 'active', 'inactive'
  int? _companyFilter;
  String? _errorMessage;

  UserProvider(this._userService);

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String get roleFilter => _roleFilter;
  String get statusFilter => _statusFilter;
  int? get companyFilter => _companyFilter;
  String? get errorMessage => _errorMessage;

  List<UserModel> get filteredUsers {
    List<UserModel> result = _users;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        final phone = (u.phone ?? '').toLowerCase();
        final company = (u.companyName ?? '').toLowerCase();
        final role = (u.roleFormatted).toLowerCase();
        return name.contains(q) ||
            email.contains(q) ||
            phone.contains(q) ||
            company.contains(q) ||
            role.contains(q);
      }).toList();
    }

    if (_roleFilter != 'all') {
      result = result.where((u) => u.role?.toLowerCase() == _roleFilter.toLowerCase()).toList();
    }

    if (_statusFilter != 'all') {
      result = result.where((u) {
        if (_statusFilter == 'active') {
          return u.isActive;
        } else {
          return !u.isActive;
        }
      }).toList();
    }

    if (_companyFilter != null) {
      result = result.where((u) => u.companyId == _companyFilter).toList();
    }

    return result;
  }

  int get totalUsersCount => _users.length;
  int get activeUsersCount => _users.where((u) => u.isActive).length;
  int get promoterAdminsCount => _users.where((u) => u.role?.toLowerCase() == 'promoter_admin').length;
  int get marketingAdminsCount => _users.where((u) => u.role?.toLowerCase() == 'marketing_team_admin').length;
  int get marketingUsersCount => _users.where((u) => u.role?.toLowerCase() == 'marketing_team_user').length;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(String role) {
    _roleFilter = role;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setCompanyFilter(int? companyId) {
    _companyFilter = companyId;
    notifyListeners();
  }

  Future<void> fetchUsers({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final fetched = await _userService.getUsers(
        page: _currentPage,
        limit: _limit,
        q: _searchQuery,
        role: _roleFilter != 'all' ? _roleFilter : null,
        status: _statusFilter != 'all' ? _statusFilter : null,
        companyId: _companyFilter,
      );

      if (reset) {
        _users = fetched;
      } else {
        _users.addAll(fetched);
      }

      _hasMore = fetched.length >= _limit;
      _currentPage++;
      _errorMessage = null;
    } catch (e, stack) {
      AppLogger.e('Error fetching users', e, stack);
      _errorMessage = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = await _userService.createUser(payload);
      _users.insert(0, newUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      AppLogger.e('Error creating user', e, stack);
      _errorMessage = 'Failed to create user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _userService.updateUser(id, payload);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updated;
      } else {
        await fetchUsers(reset: true);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      AppLogger.e('Error updating user', e, stack);
      _errorMessage = 'Failed to update user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final success = await _userService.deleteUser(id);
      if (success) {
        _users.removeWhere((u) => u.id == id);
        notifyListeners();
      }
      return success;
    } catch (e, stack) {
      AppLogger.e('Error deleting user', e, stack);
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(UserModel user) async {
    if (user.id == null) return false;
    final newStatus = user.isActive ? 'inactive' : 'active';
    return await updateUser(user.id!, {'status': newStatus});
  }
}
