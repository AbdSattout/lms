import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/ai_quiz_session_entity.dart';
import '../repositories/ai_quiz_repository.dart';

class GenerateAiQuizUseCase {
  final AiQuizRepository repository;
  GenerateAiQuizUseCase(this.repository);
  Future<Either<Failure, AiQuizSessionEntity>> call(int courseId) => repository.generate(courseId);
}