import '../entities/streak_entity.dart';
import '../repositories/gamification_repository.dart';

class GetMyStreakUseCase {
  final GamificationRepository repository;
  GetMyStreakUseCase(this.repository);
  Future<StreakEntity> call() => repository.getMyStreak();
}