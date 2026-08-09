import '../repositories/notification_repository.dart';

class DeactivateNotificationDeviceUseCase {
  final NotificationRepository repository;

  DeactivateNotificationDeviceUseCase(this.repository);

  Future<void> call(String token) {
    return repository.deactivateDevice(token);
  }
}
