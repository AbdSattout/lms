import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_quiz_details_entity.dart';
import '../repositories/practice_quiz_repository.dart';

class GetPracticeQuizDetailsUseCase {
  final PracticeQuizRepository repository;
  GetPracticeQuizDetailsUseCase(this.repository);

  Future<Either<Failure, PracticeQuizDetailsEntity>> call({
    required int courseId,
    required int quizId,
  }) => repository.getDetails(courseId: courseId, quizId: quizId);
}