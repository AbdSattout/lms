class StreakEntity {
  final int currentStreak;
  final int longestStreak;
  final int activeDays;
  final String? lastActiveDate;

  const StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDays,
    this.lastActiveDate,
  });
}