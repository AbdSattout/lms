import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_exam_details_entity.dart';
import '../entities/practice_exam_submit_result_entity.dart';
import '../entities/practice_exam_summary_entity.dart';

abstract class PracticeExamRepository {
  Future<Either<Failure, List<PracticeExamSummaryEntity>>> getList(int courseId);
  Future<Either<Failure, PracticeExamDetailsEntity>> getDetails({
    required int courseId,
    required int examId,
  });
  Future<Either<Failure, PracticeExamSubmitResultEntity>> submit({
    required int courseId,
    required int examId,
    required int attemptId,
    required Map<int, int> answers,
  });
}