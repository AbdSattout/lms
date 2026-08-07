class LeaderboardEntryEntity {
  final int userId;
  final String userName;
  final String? userPicture;
  final int level;
  final int xp;
  final int rank;

  const LeaderboardEntryEntity({
    required this.userId,
    required this.userName,
    this.userPicture,
    required this.level,
    required this.xp,
    required this.rank,
  });
}

class LeaderboardEntity {
  final String period;
  final List<LeaderboardEntryEntity> leaders;
  final LeaderboardEntryEntity? me;

  const LeaderboardEntity({
    required this.period,
    required this.leaders,
    this.me,
  });
}