import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/user_model.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyExpiresIn = 'auth_expires_in';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token methods
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> removeToken() async {
    return await _prefs.remove(_keyToken);
  }

  // Expires In methods
  Future<bool> saveExpiresIn(int expiresIn) async {
    return await _prefs.setInt(_keyExpiresIn, expiresIn);
  }

  int? getExpiresIn() {
    return _prefs.getInt(_keyExpiresIn);
  }

  Future<bool> removeExpiresIn() async {
    return await _prefs.remove(_keyExpiresIn);
  }

  // User methods
  Future<bool> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    return await _prefs.setString(_keyUser, userJson);
  }

  UserModel? getUser() {
    final userStr = _prefs.getString(_keyUser);
    if (userStr == null || userStr.isEmpty) return null;
    try {
      final map = jsonDecode(userStr) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> removeUser() async {
    return await _prefs.remove(_keyUser);
  }

  // Clear all auth data
  Future<void> clearAuth() async {
    await removeToken();
    await removeExpiresIn();
    await removeUser();
  }

  bool get isAuthenticated => getToken() != null && getToken()!.isNotEmpty;
}
