import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_quiz_summary_entity.dart';
import '../entities/practice_quiz_details_entity.dart';
import '../entities/practice_quiz_submit_result_entity.dart';

abstract class PracticeQuizRepository {
  Future<Either<Failure, List<PracticeQuizSummaryEntity>>> getList(int courseId);
  Future<Either<Failure, PracticeQuizDetailsEntity>> getDetails({
    required int courseId,
    required int quizId,
  });
  Future<Either<Failure, PracticeQuizSubmitResultEntity>> submit({
    required int courseId,
    required int quizId,
    required Map<int, int> answers,
  });
}