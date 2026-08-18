import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_exam_summary_entity.dart';
import '../repositories/practice_exam_repository.dart';

class GetPracticeExamListUseCase {
  final PracticeExamRepository repository;
  GetPracticeExamListUseCase(this.repository);

  Future<Either<Failure, List<PracticeExamSummaryEntity>>> call(int courseId) =>
      repository.getList(courseId);
}