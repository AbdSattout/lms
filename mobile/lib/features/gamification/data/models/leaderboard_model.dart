import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.name,
    super.picture,
    required super.xp,
    required super.levelNumber,
    required super.levelTitle,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String,
      picture: json['picture'] as String?,
      xp: json['xp'] as int,
      levelNumber: json['levelNumber'] as int,
      levelTitle: json['levelTitle'] as String,
    );
  }
}

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    required super.period,
    super.from,
    super.to,
    required super.leaders,
    super.me,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      period: json['period'] as String,
      from: json['from'] as String?,
      to: json['to'] as String?,
      leaders: (json['leaders'] as List<dynamic>)
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      me: json['me'] != null
          ? LeaderboardEntryModel.fromJson(json['me'] as Map<String, dynamic>)
          : null,
    );
  }
}