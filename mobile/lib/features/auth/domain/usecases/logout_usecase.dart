import '../repositories/auth_repository.dart';

class Logout {
  final AuthRepository repository;

  Logout({required this.repository});

  Future<void> call() async {
    return repository.logout();
  }
}