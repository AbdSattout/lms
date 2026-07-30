import '../../domain/entities/placement_test_entity.dart';

class PlacementQuestionModel extends PlacementQuestionEntity {
  const PlacementQuestionModel({
    required super.blockId,
    required super.lessonId,
    required super.chapterId,
    required super.questionId,
    required super.content,
    required super.options,
  });

  factory PlacementQuestionModel.fromJson(Map<String, dynamic> json) {
    return PlacementQuestionModel(
      blockId: json['blockId'] ?? 0,
      lessonId: json['lessonId'] ?? 0,
      chapterId: json['chapterId'] ?? 0,
      questionId: json['questionId'] ?? 0,
      content: json['content'] ?? '',
      options: (json['options'] as List? ?? []).map((o) => o.toString()).toList(),
    );
  }
}

class PlacementTestStateModel extends PlacementTestStateEntity {
  const PlacementTestStateModel({
    super.correct,
    required super.completed,
    required super.correctAnswers,
    required super.totalAnswers,
    super.remainingHearts,
    super.question,
    super.startBlockId,
    super.startLessonId,
    super.startChapterId,
    required super.progressPercentage,
    required super.message,
  });

  factory PlacementTestStateModel.fromJson(Map<String, dynamic> json) {
    final questionJson = json['question'] ?? json['nextQuestion'];

    return PlacementTestStateModel(
      correct: json['correct'],
      completed: json['completed'] ?? false,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalAnswers: json['totalAnswers'] ?? 0,
      remainingHearts: json['remainingHearts'],
      question: questionJson != null
          ? PlacementQuestionModel.fromJson(questionJson as Map<String, dynamic>)
          : null,
      startBlockId: json['startBlockId'],
      startLessonId: json['startLessonId'],
      startChapterId: json['startChapterId'],
      progressPercentage:
      (json['progressPercentage'] as num?)?.toDouble() ?? 0,
      message: json['message'] ?? '',
    );
  }
}