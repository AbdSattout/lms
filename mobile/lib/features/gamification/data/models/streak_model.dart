import '../../domain/entities/streak_entity.dart';

class StreakModel extends StreakEntity {
  const StreakModel({
    required super.currentStreak,
    required super.longestStreak,
    required super.activeDays,
    super.lastActiveDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      activeDays: json['activeDays'] ?? 0,
      lastActiveDate: json['lastActiveDate'],
    );
  }
}