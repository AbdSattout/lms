class LeaderboardEntryEntity {
  final int rank;
  final int userId;
  final String name;
  final String? picture;
  final int xp;
  final int levelNumber;
  final String levelTitle;

  const LeaderboardEntryEntity({
    required this.rank,
    required this.userId,
    required this.name,
    this.picture,
    required this.xp,
    required this.levelNumber,
    required this.levelTitle,
  });
}

class LeaderboardEntity {
  final String period;
  final String? from;
  final String? to;
  final List<LeaderboardEntryEntity> leaders;
  final LeaderboardEntryEntity? me;

  const LeaderboardEntity({
    required this.period,
    this.from,
    this.to,
    required this.leaders,
    this.me,
  });
}