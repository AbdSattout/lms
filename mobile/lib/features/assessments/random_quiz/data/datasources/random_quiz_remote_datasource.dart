import '../../../../../core/databases/api/end_points.dart';
import '../../../../../core/databases/api/api_consumer.dart';
import '../models/random_quiz_session_model.dart';
import '../models/random_quiz_submit_result_model.dart';

abstract class RandomQuizRemoteDataSource {
  Future<RandomQuizSessionModel> generate({
    required int courseId,
    required String difficulty,
    required int count,
  });

  Future<RandomQuizSubmitResultModel> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  });
}

class RandomQuizRemoteDataSourceImpl implements RandomQuizRemoteDataSource {
  final ApiConsumer api;

  RandomQuizRemoteDataSourceImpl({required this.api});

  @override
  Future<RandomQuizSessionModel> generate({
    required int courseId,
    required String difficulty,
    required int count,
  }) async {
    final response = await api.post(
      EndPoints.generateRandomQuiz(courseId),
      data: {'difficulty': difficulty, 'count': count},
    );
    return RandomQuizSessionModel.fromJson(response);
  }

  @override
  Future<RandomQuizSubmitResultModel> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  }) async {
    final response = await api.post(
      EndPoints.submitRandomQuiz(courseId, attemptId),
      data: {
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'answerIndex': e.value})
            .toList(),
      },
    );
    return RandomQuizSubmitResultModel.fromJson(response);
  }
}