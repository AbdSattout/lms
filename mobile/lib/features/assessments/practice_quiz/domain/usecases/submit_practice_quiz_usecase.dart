import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_quiz_submit_result_entity.dart';
import '../repositories/practice_quiz_repository.dart';

class SubmitPracticeQuizUseCase {
  final PracticeQuizRepository repository;
  SubmitPracticeQuizUseCase(this.repository);

  Future<Either<Failure, PracticeQuizSubmitResultEntity>> call({
    required int courseId,
    required int quizId,
    required Map<int, int> answers,
  }) => repository.submit(courseId: courseId, quizId: quizId, answers: answers);
}