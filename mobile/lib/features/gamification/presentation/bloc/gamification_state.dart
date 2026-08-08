import '../../domain/entities/gamification_progress_entity.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';

abstract class GamificationState {}

class GamificationInitial extends GamificationState {}

class GamificationLoading extends GamificationState {}

class GamificationLoaded extends GamificationState {
  final GamificationProgressEntity progress;
  final StreakEntity streak;
  final List<ActivityEntity> activities;
  GamificationLoaded({
  required this.progress,
  required this.streak,
  required this.activities,
});
}

class LeaderboardLoaded extends GamificationState {
  final LeaderboardEntity leaderboard;
  LeaderboardLoaded(this.leaderboard);
}

class GamificationError extends GamificationState {
  final String message;
  GamificationError(this.message);
}