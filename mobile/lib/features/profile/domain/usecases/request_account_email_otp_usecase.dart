import '../repositories/profile_repository.dart';

class RequestAccountEmailOtpUseCase {
  final ProfileRepository repository;

  RequestAccountEmailOtpUseCase(this.repository);

  Future<void> call(String email) {
    return repository.requestAccountEmailOtp(email);
  }
}
