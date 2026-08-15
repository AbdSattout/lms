import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/ai_quiz_submit_result_entity.dart';
import '../repositories/ai_quiz_repository.dart';

class SubmitAiQuizUseCase {
  final AiQuizRepository repository;
  SubmitAiQuizUseCase(this.repository);
  Future<Either<Failure, AiQuizSubmitResultEntity>> call({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  }) => repository.submit(courseId: courseId, attemptId: attemptId, answers: answers);
}