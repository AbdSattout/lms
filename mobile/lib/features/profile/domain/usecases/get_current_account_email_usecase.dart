import '../repositories/profile_repository.dart';

class GetCurrentAccountEmailUseCase {
  final ProfileRepository repository;

  GetCurrentAccountEmailUseCase(this.repository);

  Future<String?> call() {
    return repository.getCurrentAccountEmail();
  }
}
