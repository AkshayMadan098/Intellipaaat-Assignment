import '../repositories/course_repository.dart';

class SyncPendingMutationsUseCase {
  final CourseRepository _repository;

  SyncPendingMutationsUseCase(this._repository);

  Future<void> execute() {
    return _repository.syncPendingMutations();
  }
}
