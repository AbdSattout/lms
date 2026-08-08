import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtp {
  final AuthRepository repository;

  VerifyEmailOtp({required this.repository});

  Future<Either<Failure, AuthEntity>> call({
    required String email,
    required String otp,
  }) {
    return repository.verifyEmailOtp(email: email, otp: otp);
  }
}
