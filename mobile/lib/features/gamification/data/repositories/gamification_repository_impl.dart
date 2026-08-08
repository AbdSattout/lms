import '../../domain/entities/gamification_progress_entity.dart';
import '../../domain/entities/streak_entity.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_datasource.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;

  GamificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<GamificationProgressEntity> getMyProgress() async {
    return await remoteDataSource.getMyProgress();
  }

  @override
  Future<StreakEntity> getMyStreak() async {
    return await remoteDataSource.getMyStreak();
  }

  @override
  Future<List<ActivityEntity>> getActivity({String? from, String? to}) async {
    return await remoteDataSource.getActivity(from: from, to: to);
  }

  @override
  Future<LeaderboardEntity> getLeaderboard({
    required String period,
    int? limit,
  }) async {
    return await remoteDataSource.getLeaderboard(period: period, limit: limit);
  }
}