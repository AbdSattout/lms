import '../../../core/data/models/quiz_question_result_model.dart';
import '../../domain/entities/practice_exam_submit_result_entity.dart';

class PracticeExamSubmitResultModel extends PracticeExamSubmitResultEntity {
  const PracticeExamSubmitResultModel({
    required super.attemptId,
    required super.score,
    required super.total,
    required super.results,
    super.rewards,
    super.badges,
  });

  factory PracticeExamSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return PracticeExamSubmitResultModel(
      attemptId: json['attemptId'] as int,
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewards: (json['rewards'] as List<dynamic>? ?? [])
          .map((e) => GamificationAwardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GamificationAwardModel extends GamificationAwardEntity {
  const GamificationAwardModel({
    required super.eventType,
    super.referenceId,
    required super.awarded,
    required super.xpAwarded,
    required super.totalXp,
    required super.previousLevelNumber,
    required super.currentLevelNumber,
    required super.currentLevelTitle,
    required super.leveledUp,
  });

  factory GamificationAwardModel.fromJson(Map<String, dynamic> json) {
    return GamificationAwardModel(
      eventType: json['eventType'] as String? ?? '',
      referenceId: json['referenceId'] as int?,
      awarded: json['awarded'] as bool? ?? false,
      xpAwarded: json['xpAwarded'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      previousLevelNumber: json['previousLevelNumber'] as int? ?? 0,
      currentLevelNumber: json['currentLevelNumber'] as int? ?? 0,
      currentLevelTitle: json['currentLevelTitle'] as String? ?? '',
      leveledUp: json['leveledUp'] as bool? ?? false,
    );
  }
}

class UserBadgeModel extends UserBadgeEntity {
  const UserBadgeModel({
    required super.badgeId,
    required super.userBadgeId,
    required super.code,
    required super.title,
    required super.description,
    super.iconUrl,
    super.earnedAt,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      badgeId: json['badgeId'] as int? ?? 0,
      userBadgeId: json['userBadgeId'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['iconUrl'] as String?,
      earnedAt: json['earnedAt'] as String?,
    );
  }
}