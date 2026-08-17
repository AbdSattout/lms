import '../../../../../core/databases/api/api_consumer.dart';
import '../../../../../core/databases/api/end_points.dart';
import '../models/final_exam_details_model.dart';
import '../models/final_exam_submit_result_model.dart';

abstract class FinalExamRemoteDataSource {
  Future<FinalExamDetailsModel> getExam(int courseId);
  Future<FinalExamSubmitResultModel> submit({
    required int courseId,
    required Map<int, int> answers,
  });
}

class FinalExamRemoteDataSourceImpl implements FinalExamRemoteDataSource {
  final ApiConsumer api;

  FinalExamRemoteDataSourceImpl({required this.api});

  @override
  Future<FinalExamDetailsModel> getExam(int courseId) async {
    final response = await api.get(EndPoints.finalExam(courseId));
    return FinalExamDetailsModel.fromJson(response);
  }

  @override
  Future<FinalExamSubmitResultModel> submit({
    required int courseId,
    required Map<int, int> answers,
  }) async {
    final response = await api.post(
      EndPoints.submitFinalExam(courseId),
      data: {
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'answerIndex': e.value})
            .toList(),
      },
    );
    return FinalExamSubmitResultModel.fromJson(response);
  }
}