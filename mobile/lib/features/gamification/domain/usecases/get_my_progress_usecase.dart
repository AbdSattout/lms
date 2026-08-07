import '../entities/gamification_progress_entity.dart';
import '../repositories/gamification_repository.dart';

class GetMyProgressUseCase {
  final GamificationRepository repository;
  GetMyProgressUseCase(this.repository);
  Future<GamificationProgressEntity> call() => repository.getMyProgress();
}