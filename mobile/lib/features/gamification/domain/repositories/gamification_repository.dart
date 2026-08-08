import '../entities/gamification_progress_entity.dart';
import '../entities/streak_entity.dart';
import '../entities/activity_entity.dart';
import '../entities/leaderboard_entity.dart';

abstract class GamificationRepository {
  Future<GamificationProgressEntity> getMyProgress();
  Future<StreakEntity> getMyStreak();
  Future<List<ActivityEntity>> getActivity({String? from, String? to});
  Future<LeaderboardEntity> getLeaderboard({required String period, int? limit});
}