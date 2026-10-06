import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginState());

  void emailChanged(String email) {
    emit(state.copyWith(
      email: email,
      clearEmailError: true,
      clearErrorMessage: true,
    ));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
      password: password,
      clearPasswordError: true,
      clearErrorMessage: true,
    ));
  }

  bool validate() {
    bool isValid = true;
    String? emailError;
    String? passwordError;

    final trimmedEmail = state.email.trim();
    if (trimmedEmail.isEmpty) {
      emailError = 'Email is required';
      isValid = false;
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(trimmedEmail)) {
        emailError = 'Please enter a valid email address';
        isValid = false;
      }
    }

    if (state.password.isEmpty) {
      passwordError = 'Password is required';
      isValid = false;
    } else if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    emit(state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      clearEmailError: emailError == null,
      clearPasswordError: passwordError == null,
    ));

    return isValid;
  }

  Future<void> login() async {
    if (!validate()) return;

    emit(state.copyWith(
      status: LoginStatus.loading,
      clearErrorMessage: true,
    ));

    try {
      final user = await _loginUseCase.execute(
        email: state.email.trim(),
        password: state.password,
      );
      emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'An unexpected error occurred: $e',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(clearErrorMessage: true));
  }
}
