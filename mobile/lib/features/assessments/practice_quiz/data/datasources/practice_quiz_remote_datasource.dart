import '../../../../../core/databases/api/api_consumer.dart';
import '../../../../../core/databases/api/end_points.dart';
import '../models/practice_quiz_summary_model.dart';
import '../models/practice_quiz_details_model.dart';
import '../models/practice_quiz_submit_result_model.dart';

abstract class PracticeQuizRemoteDataSource {
  Future<List<PracticeQuizSummaryModel>> getList(int courseId);
  Future<PracticeQuizDetailsModel> getDetails({
    required int courseId,
    required int quizId,
  });
  Future<PracticeQuizSubmitResultModel> submit({
    required int courseId,
    required int quizId,
    required Map<int, int> answers,
  });
}

class PracticeQuizRemoteDataSourceImpl implements PracticeQuizRemoteDataSource {
  final ApiConsumer api;

  PracticeQuizRemoteDataSourceImpl({required this.api});

  @override
  Future<List<PracticeQuizSummaryModel>> getList(int courseId) async {
    final response = await api.get(EndPoints.practiceQuizList(courseId));
    return (response as List<dynamic>)
        .map((e) => PracticeQuizSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PracticeQuizDetailsModel> getDetails({
    required int courseId,
    required int quizId,
  }) async {
    final response = await api.get(EndPoints.practiceQuizDetails(courseId, quizId));
    return PracticeQuizDetailsModel.fromJson(response);
  }

  @override
  Future<PracticeQuizSubmitResultModel> submit({
    required int courseId,
    required int quizId,
    required Map<int, int> answers,
  }) async {
    final response = await api.post(
      EndPoints.submitPracticeQuiz(courseId, quizId),
      data: {
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'answerIndex': e.value})
            .toList(),
      },
    );
    return PracticeQuizSubmitResultModel.fromJson(response);
  }
}