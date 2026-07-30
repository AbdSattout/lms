import '../../domain/entities/block_content_entity.dart';
import 'course_model.dart' show RewardModel;

class BlockQuestionModel extends BlockQuestionEntity {
  const BlockQuestionModel({
    required super.id,
    required super.content,
    required super.options,
  });

  factory BlockQuestionModel.fromJson(Map<String, dynamic> json) {
    return BlockQuestionModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      options:
      (json['options'] as List? ?? []).map((o) => o.toString()).toList(),
    );
  }
}

class BlockContentModel extends BlockContentEntity {
  const BlockContentModel({
    required super.id,
    required super.title,
    required super.content,
    required super.position,
    super.question,
  });

  factory BlockContentModel.fromJson(Map<String, dynamic> json) {
    return BlockContentModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      position: json['position'] ?? 0,
      question: json['question'] != null
          ? BlockQuestionModel.fromJson(json['question'] as Map<String, dynamic>)
          : null,
    );
  }
}

class BlockAnswerResultModel extends BlockAnswerResultEntity {
  const BlockAnswerResultModel({
    required super.nextType,
    super.nextBlockId,
    super.nextLessonId,
    super.nextChapterId,
    super.quizId,
    required super.message,
    super.rewards,
  });

  factory BlockAnswerResultModel.fromJson(Map<String, dynamic> json) {
    return BlockAnswerResultModel(
      nextType: json['nextType'] ?? '',
      nextBlockId: json['nextBlockId'],
      nextLessonId: json['nextLessonId'],
      nextChapterId: json['nextChapterId'],
      quizId: json['quizId'],
      message: json['message'] ?? '',
      rewards: (json['rewards'] as List? ?? [])
          .map((r) => RewardModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}