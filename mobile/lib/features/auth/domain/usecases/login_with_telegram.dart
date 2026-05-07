import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithTelegram {
  final AuthRepository repository;

  LoginWithTelegram({required this.repository});

  Future<Either<Failure, AuthEntity>> call() {
    return repository.loginWithTelegram();
  }
}