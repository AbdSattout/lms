import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.userId,
    required super.userName,
    super.userPicture,
    required super.level,
    required super.xp,
    required super.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userPicture: json['userPicture'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.period,
    required super.leaders,
    super.me,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      period: json['period'] ?? 'WEEKLY',
      leaders: (json['leaders'] as List<dynamic>?)
          ?.map((e) => LeaderboardEntryModel.fromJson(e))
          .toList() ??
          [],
      me: json['me'] != null
          ? LeaderboardEntryModel.fromJson(json['me'])
          : null,
    );
  }
}