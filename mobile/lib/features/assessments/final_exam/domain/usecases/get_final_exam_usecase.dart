import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/final_exam_details_entity.dart';
import '../repositories/final_exam_repository.dart';

class GetFinalExamUseCase {
  final FinalExamRepository repository;
  GetFinalExamUseCase(this.repository);

  Future<Either<Failure, FinalExamDetailsEntity>> call(int courseId) =>
      repository.getExam(courseId);
}