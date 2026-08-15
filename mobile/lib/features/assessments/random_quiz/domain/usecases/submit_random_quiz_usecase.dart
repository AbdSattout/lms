import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/random_quiz_submit_result_entity.dart';
import '../repositories/random_quiz_repository.dart';

class SubmitRandomQuizUseCase {
  final RandomQuizRepository repository;
  SubmitRandomQuizUseCase(this.repository);

  Future<Either<Failure, RandomQuizSubmitResultEntity>> call({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  }) => repository.submit(courseId: courseId, attemptId: attemptId, answers: answers);
}