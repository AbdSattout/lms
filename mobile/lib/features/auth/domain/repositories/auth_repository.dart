import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> loginWithTelegram();
  Future<Either<Failure, AuthEntity>> loginWithGoogle();
  Future<Either<Failure, bool>> requestEmailOtp(String email);
  Future<Either<Failure, AuthEntity>> verifyEmailOtp({
    required String email,
    required String otp,
  });
  Future<Either<Failure, AuthEntity?>> checkCachedAuth();
  Future<void> logout();
}
