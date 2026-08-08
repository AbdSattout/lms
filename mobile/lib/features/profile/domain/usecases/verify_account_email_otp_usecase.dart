import '../repositories/profile_repository.dart';

class VerifyAccountEmailOtpUseCase {
  final ProfileRepository repository;

  VerifyAccountEmailOtpUseCase(this.repository);

  Future<String?> call({required String email, required String otp}) {
    return repository.verifyAccountEmailOtp(email: email, otp: otp);
  }
}
