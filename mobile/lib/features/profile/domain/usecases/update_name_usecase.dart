import '../repositories/profile_repository.dart';
class UpdateNameUseCase {
  final ProfileRepository repository;
  UpdateNameUseCase(this.repository);
  Future<void> call(String name) => repository.updateName(name);
}