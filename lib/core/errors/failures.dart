// Core failure and exception definitions

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to load cached data.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid email or password.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Input validation failed.']);
}
