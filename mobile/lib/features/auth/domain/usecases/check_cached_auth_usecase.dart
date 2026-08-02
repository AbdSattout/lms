import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class CheckCachedAuth {
  final AuthRepository repository;

  CheckCachedAuth({required this.repository});

  Future<Either<Failure, AuthEntity?>> call() {
    return repository.checkCachedAuth();
  }
}