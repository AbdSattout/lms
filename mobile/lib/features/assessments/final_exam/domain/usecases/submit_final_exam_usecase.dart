import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/final_exam_submit_result_entity.dart';
import '../repositories/final_exam_repository.dart';

class SubmitFinalExamUseCase {
  final FinalExamRepository repository;
  SubmitFinalExamUseCase(this.repository);

  Future<Either<Failure, FinalExamSubmitResultEntity>> call({
    required int courseId,
    required Map<int, int> answers,
  }) => repository.submit(courseId: courseId, answers: answers);
}