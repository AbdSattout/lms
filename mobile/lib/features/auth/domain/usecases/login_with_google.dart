import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository repository;

  LoginWithGoogle({required this.repository});

  Future<Either<Failure, AuthEntity>> call() {
    return repository.loginWithGoogle();
  }
}
