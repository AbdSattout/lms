import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/random_quiz_session_entity.dart';
import '../repositories/random_quiz_repository.dart';

class GenerateRandomQuizUseCase {
  final RandomQuizRepository repository;
  GenerateRandomQuizUseCase(this.repository);

  Future<Either<Failure, RandomQuizSessionEntity>> call({
    required int courseId,
    required String difficulty,
    required int count,
  }) => repository.generate(courseId: courseId, difficulty: difficulty, count: count);
}