import '../../../../../core/databases/api/api_consumer.dart';
import '../../../../../core/databases/api/end_points.dart';
import '../models/practice_exam_summary_model.dart';
import '../models/practice_exam_details_model.dart';
import '../models/practice_exam_submit_result_model.dart';

abstract class PracticeExamRemoteDataSource {
  Future<List<PracticeExamSummaryModel>> getList(int courseId);
  Future<PracticeExamDetailsModel> getDetails({required int courseId, required int examId});
  Future<PracticeExamSubmitResultModel> submit({
    required int courseId,
    required int examId,
    required int attemptId,
    required Map<int, int> answers,
  });
}

class PracticeExamRemoteDataSourceImpl implements PracticeExamRemoteDataSource {
  final ApiConsumer api;

  PracticeExamRemoteDataSourceImpl({required this.api});

  @override
  Future<List<PracticeExamSummaryModel>> getList(int courseId) async {
    final response = await api.get(EndPoints.practiceExamList(courseId));
    return (response as List<dynamic>)
        .map((e) => PracticeExamSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PracticeExamDetailsModel> getDetails({required int courseId, required int examId}) async {
    final response = await api.get(EndPoints.practiceExamDetails(courseId, examId));
    return PracticeExamDetailsModel.fromJson(response);
  }

  @override
  Future<PracticeExamSubmitResultModel> submit({
    required int courseId,
    required int examId,
    required int attemptId,
    required Map<int, int> answers,
  }) async {
    final response = await api.post(
      EndPoints.submitPracticeExam(courseId, examId),
      data: {
        'attemptId': attemptId,
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'answerIndex': e.value})
            .toList(),
      },
    );
    return PracticeExamSubmitResultModel.fromJson(response);
  }
}