import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;
  final User? user;

  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.errorMessage,
    this.user,
  });

  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isFailure => status == LoginStatus.failure;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? errorMessage,
    User? user,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        emailError,
        passwordError,
        errorMessage,
        user,
      ];
}
