import '../../../core/domain/entities/quiz_question_result_entity.dart';
import '../../../core/domain/entities/certificate_entity.dart';
import '../../../practice_exam/domain/entities/practice_exam_submit_result_entity.dart'
    show GamificationAwardEntity, UserBadgeEntity;

class FinalExamSubmitResultEntity {
  final int attemptId;
  final int score;
  final int total;
  final List<QuizQuestionResultEntity> results;
  final List<GamificationAwardEntity> rewards;
  final CertificateEntity? certificate;
  final List<UserBadgeEntity> badges;

  const FinalExamSubmitResultEntity({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.results,
    this.rewards = const [],
    this.certificate,
    this.badges = const [],
  });

  double get percentage => total == 0 ? 0 : (score / total) * 100;
  int get totalXpEarned => rewards.where((r) => r.awarded).fold(0, (sum, r) => sum + r.xpAwarded);
  bool get hasLeveledUp => rewards.any((r) => r.leveledUp);
}