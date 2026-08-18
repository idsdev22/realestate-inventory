import 'package:flutter/foundation.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

enum UserRole {
  admin,
  marketingTeam,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  UserRole _currentRole = UserRole.admin;

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isInitialized => _isInitialized;
  UserRole get currentRole => _currentRole;
  bool get isAdmin => _currentRole == UserRole.admin;

  String get displayName {
    if (_currentRole == UserRole.admin) {
      return 'Admin';
    } else {
      return 'ABC Marketing';
    }
  }

  void setRole(UserRole role) {
    _currentRole = role;
    if (_user != null) {
      _user = _user!.copyWith(
        role: role == UserRole.admin ? 'promoter_admin' : 'marketing_team',
        email: role == UserRole.admin ? 'admin@syncr.test' : 'abcmarketing@gmail.com',
      );
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = _storageService.getToken();
      _user = _storageService.getUser();

      if (_token != null && _token!.isNotEmpty) {
        if (_user != null && _user!.role == 'marketing_team') {
          _currentRole = UserRole.marketingTeam;
        } else {
          _currentRole = UserRole.admin;
        }
        await fetchMe();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    UserRole selectedRole = UserRole.admin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentRole = selectedRole;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.token != null) {
        _token = response.token;
        _user = response.user ?? UserModel(
          email: email,
          role: selectedRole == UserRole.admin ? 'promoter_admin' : 'marketing_team',
        );

        await _storageService.saveToken(_token!);
        if (_user != null) {
          await _storageService.saveUser(_user!);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
      return success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to request password reset. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMe() async {
    try {
      final user = await _authService.getMe();
      if (user != null) {
        _user = user;
        if (user.role == 'marketing_team') {
          _currentRole = UserRole.marketingTeam;
        }
        await _storageService.saveUser(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch user me: $e');
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _storageService.clearAuth();
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
