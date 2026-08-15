import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_quiz_summary_entity.dart';
import '../repositories/practice_quiz_repository.dart';

class GetPracticeQuizListUseCase {
  final PracticeQuizRepository repository;
  GetPracticeQuizListUseCase(this.repository);

  Future<Either<Failure, List<PracticeQuizSummaryEntity>>> call(int courseId) =>
      repository.getList(courseId);
}