import '../repositories/notification_repository.dart';

class RegisterNotificationDeviceUseCase {
  final NotificationRepository repository;

  RegisterNotificationDeviceUseCase(this.repository);

  Future<void> call(String token) {
    return repository.registerDevice(token);
  }
}
