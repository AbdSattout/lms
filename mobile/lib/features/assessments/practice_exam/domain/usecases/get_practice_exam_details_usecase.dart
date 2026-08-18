import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/practice_exam_details_entity.dart';
import '../repositories/practice_exam_repository.dart';

class GetPracticeExamDetailsUseCase {
  final PracticeExamRepository repository;
  GetPracticeExamDetailsUseCase(this.repository);

  Future<Either<Failure, PracticeExamDetailsEntity>> call({
    required int courseId,
    required int examId,
  }) => repository.getDetails(courseId: courseId, examId: examId);
}