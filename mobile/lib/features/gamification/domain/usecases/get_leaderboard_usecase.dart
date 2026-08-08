import '../entities/leaderboard_entity.dart';
import '../repositories/gamification_repository.dart';

class GetLeaderboardUseCase {
  final GamificationRepository repository;
  GetLeaderboardUseCase(this.repository);
  Future<LeaderboardEntity> call({required String period, int? limit}) =>
      repository.getLeaderboard(period: period, limit: limit);
}