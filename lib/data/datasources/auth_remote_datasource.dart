import 'dart:async';
import '../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  void setSimulatedError(bool shouldFail);
  bool get isSimulatedError;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  bool _simulatedError = false;

  @override
  bool get isSimulatedError => _simulatedError;

  @override
  void setSimulatedError(bool shouldFail) {
    _simulatedError = shouldFail;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    // Simulate real network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (_simulatedError) {
      throw const ServerFailure('Authentication service is temporarily unavailable.');
    }

    // Input sanitization and validation
    final trimmedEmail = email.trim();
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw const ValidationFailure('Please provide a valid email address.');
    }
    if (password.length < 6) {
      throw const ValidationFailure('Password must be at least 6 characters.');
    }

    // Demo check: reject intentionally invalid credentials if someone types 'wrong@example.com' or 'wrongpassword'
    if (password == 'wrongpassword') {
      throw const AuthFailure('Invalid credentials. Please verify your email and password.');
    }

    // Derive display name from email (e.g. john from john.doe@example.com)
    final usernamePart = trimmedEmail.split('@').first;
    final displayName = usernamePart
        .split(RegExp(r'[._]'))
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    return UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: trimmedEmail,
      name: displayName.isNotEmpty ? displayName : 'Student User',
      token: 'jwt_mock_token_${DateTime.now().millisecondsSinceEpoch}_xyz987',
    );
  }
}
