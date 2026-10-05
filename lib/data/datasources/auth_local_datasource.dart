import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthData({required UserModel user, required String token});
  Future<UserModel?> getUser();
  Future<String?> getToken();
  Future<void> clearAuth();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _kUserKey = 'auth_user_data';
  static const _kTokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage;

  AuthLocalDataSourceImpl([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> saveAuthData({required UserModel user, required String token}) async {
    await _secureStorage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
    await _secureStorage.write(key: _kTokenKey, value: token);
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = await _secureStorage.read(key: _kUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.read(key: _kTokenKey);
  }

  @override
  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _kUserKey);
    await _secureStorage.delete(key: _kTokenKey);
  }
}
