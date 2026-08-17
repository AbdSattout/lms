import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_exam_submit_result_entity.dart';
import '../repositories/practice_exam_repository.dart';

class SubmitPracticeExamUseCase {
  final PracticeExamRepository repository;
  SubmitPracticeExamUseCase(this.repository);

  Future<Either<Failure, PracticeExamSubmitResultEntity>> call({
    required int courseId,
    required int examId,
    required int attemptId,
    required Map<int, int> answers,
  }) => repository.submit(courseId: courseId, examId: examId, attemptId: attemptId, answers: answers);
}