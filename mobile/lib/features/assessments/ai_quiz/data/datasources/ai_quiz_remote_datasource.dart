
import '../../../../../core/databases/api/api_consumer.dart';
import '../../../../../core/databases/api/end_points.dart';
import '../models/ai_quiz_session_model.dart';
import '../models/ai_quiz_submit_result_model.dart';

abstract class AiQuizRemoteDataSource {
  Future<AiQuizSessionModel> generate(int courseId);
  Future<AiQuizSubmitResultModel> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  });
}

class AiQuizRemoteDataSourceImpl implements AiQuizRemoteDataSource {
  final ApiConsumer api;

  AiQuizRemoteDataSourceImpl({required this.api});

  @override
  Future<AiQuizSessionModel> generate(int courseId) async {
    final response = await api.post(EndPoints.generateAiQuiz(courseId));
    return AiQuizSessionModel.fromJson(response);
  }

  @override
  Future<AiQuizSubmitResultModel> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  }) async {
    final response = await api.post(
      EndPoints.submitAiQuiz(courseId, attemptId),
      data: {
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'answerIndex': e.value})
            .toList(),
      },
    );
    return AiQuizSubmitResultModel.fromJson(response);
  }
}