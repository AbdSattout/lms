import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/auth_repository.dart';

class RequestEmailOtp {
  final AuthRepository repository;

  RequestEmailOtp({required this.repository});

  Future<Either<Failure, bool>> call(String email) {
    return repository.requestEmailOtp(email);
  }
}
