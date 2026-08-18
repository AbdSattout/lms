import '../../../core/domain/entities/quiz_question_result_entity.dart';

class GamificationAwardEntity {
  final String eventType;
  final int? referenceId;
  final bool awarded;
  final int xpAwarded;
  final int totalXp;
  final int previousLevelNumber;
  final int currentLevelNumber;
  final String currentLevelTitle;
  final bool leveledUp;

  const GamificationAwardEntity({
    required this.eventType,
    this.referenceId,
    required this.awarded,
    required this.xpAwarded,
    required this.totalXp,
    required this.previousLevelNumber,
    required this.currentLevelNumber,
    required this.currentLevelTitle,
    required this.leveledUp,
  });
}

class UserBadgeEntity {
  final int badgeId;
  final int userBadgeId;
  final String code;
  final String title;
  final String description;
  final String? iconUrl;
  final String? earnedAt;

  const UserBadgeEntity({
    required this.badgeId,
    required this.userBadgeId,
    required this.code,
    required this.title,
    required this.description,
    this.iconUrl,
    this.earnedAt,
  });
}

class PracticeExamSubmitResultEntity {
  final int attemptId;
  final int score;
  final int total;
  final List<QuizQuestionResultEntity> results;
  final List<GamificationAwardEntity> rewards;
  final List<UserBadgeEntity> badges;

  const PracticeExamSubmitResultEntity({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.results,
    this.rewards = const [],
    this.badges = const [],
  });

  double get percentage => total == 0 ? 0 : (score / total) * 100;
  int get totalXpEarned => rewards.where((r) => r.awarded).fold(0, (sum, r) => sum + r.xpAwarded);
  bool get hasLeveledUp => rewards.any((r) => r.leveledUp);
}