import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:new_project/data/datasources/auth_local_datasource.dart';
import 'package:new_project/data/datasources/auth_remote_datasource.dart';
import 'package:new_project/data/repositories/auth_repository_impl.dart';
import 'package:new_project/domain/usecases/login_usecase.dart';
import 'package:new_project/presentation/cubits/login/login_cubit.dart';
import 'package:new_project/presentation/cubits/login/login_state.dart';

void main() {
  late AuthRepositoryImpl authRepository;
  late LoginUseCase loginUseCase;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    const secureStorage = FlutterSecureStorage();
    final localDataSource = AuthLocalDataSourceImpl(secureStorage);
    final remoteDataSource = AuthRemoteDataSourceImpl();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
    loginUseCase = LoginUseCase(authRepository);
  });

  group('LoginCubit', () {
    test('initial state has default empty values', () {
      final cubit = LoginCubit(loginUseCase);
      expect(cubit.state, equals(const LoginState()));
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.isSuccess, isFalse);
      expect(cubit.state.isFailure, isFalse);
    });

    blocTest<LoginCubit, LoginState>(
      'emits updated email and password on input change',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) {
        cubit.emailChanged('student@example.com');
        cubit.passwordChanged('secret123');
      },
      expect: () => [
        const LoginState(email: 'student@example.com'),
        const LoginState(email: 'student@example.com', password: 'secret123'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'validates email and password format before login attempt',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) {
        cubit.emailChanged('invalid-email');
        cubit.passwordChanged('123');
        cubit.validate();
      },
      verify: (cubit) {
        expect(cubit.state.emailError, contains('valid email'));
        expect(cubit.state.passwordError, contains('at least 6 characters'));
      },
    );

    blocTest<LoginCubit, LoginState>(
      'emits [loading, success] on successful credentials authentication',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) async {
        cubit.emailChanged('student@example.com');
        cubit.passwordChanged('password123');
        await cubit.login();
      },
      expect: () => [
        const LoginState(email: 'student@example.com'),
        const LoginState(email: 'student@example.com', password: 'password123'),
        const LoginState(
          status: LoginStatus.loading,
          email: 'student@example.com',
          password: 'password123',
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.user?.email, 'user.email', 'student@example.com'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [loading, failure] when invalid password is provided',
      build: () => LoginCubit(loginUseCase),
      act: (cubit) async {
        cubit.emailChanged('demo@example.com');
        cubit.passwordChanged('wrongpassword');
        await cubit.login();
      },
      expect: () => [
        const LoginState(email: 'demo@example.com'),
        const LoginState(
          email: 'demo@example.com',
          password: 'wrongpassword',
        ),
        const LoginState(
          status: LoginStatus.loading,
          email: 'demo@example.com',
          password: 'wrongpassword',
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('Invalid credentials')),
      ],
    );
  });
}
