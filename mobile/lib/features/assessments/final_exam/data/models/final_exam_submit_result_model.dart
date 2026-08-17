import '../../../core/data/models/quiz_question_result_model.dart';
import '../../../core/data/models/certificate_model.dart';
import '../../../practice_exam/data/models/practice_exam_submit_result_model.dart'
    show GamificationAwardModel, UserBadgeModel;
import '../../domain/entities/final_exam_submit_result_entity.dart';

class FinalExamSubmitResultModel extends FinalExamSubmitResultEntity {
  const FinalExamSubmitResultModel({
    required super.attemptId,
    required super.score,
    required super.total,
    required super.results,
    super.rewards,
    super.certificate,
    super.badges,
  });

  factory FinalExamSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return FinalExamSubmitResultModel(
      attemptId: json['attemptId'] as int,
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rewards: (json['rewards'] as List<dynamic>? ?? [])
          .map((e) => GamificationAwardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      certificate: json['certificate'] != null
          ? CertificateModel.fromJson(json['certificate'] as Map<String, dynamic>)
          : null,
      badges: (json['badges'] as List<dynamic>? ?? [])
          .map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}