import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/gamification_progress_model.dart';
import '../models/streak_model.dart';
import '../models/activity_model.dart';
import '../models/leaderboard_model.dart';

abstract class GamificationRemoteDataSource {
  Future<GamificationProgressModel> getMyProgress();
  Future<StreakModel> getMyStreak();
  Future<List<ActivityModel>> getActivity({String? from, String? to});
  Future<LeaderboardModel> getLeaderboard({required String period, int? limit});
}

class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final ApiConsumer api;

  GamificationRemoteDataSourceImpl({required this.api});

  @override
  Future<GamificationProgressModel> getMyProgress() async {
    final response = await api.get(EndPoints.gamificationMe);
    return GamificationProgressModel.fromJson(response);
  }

  @override
  Future<StreakModel> getMyStreak() async {
    final response = await api.get(EndPoints.gamificationStreak);
    return StreakModel.fromJson(response);
  }

  @override
  Future<List<ActivityModel>> getActivity({String? from, String? to}) async {
    String path = EndPoints.gamificationActivity;
    if (from != null && to != null) {
      path += '?from=$from&to=$to';
    }
    final response = await api.get(path);
    return (response as List<dynamic>)
        .map((e) => ActivityModel.fromJson(e))
        .toList();
  }

  @override
  Future<LeaderboardModel> getLeaderboard({
    required String period,
    int? limit,
  }) async {
    String path = '${EndPoints.gamificationScoreboard}?period=$period';
    if (limit != null) {
      path += '&limit=$limit';
    }
    final response = await api.get(path);
    return LeaderboardModel.fromJson(response);
  }
}