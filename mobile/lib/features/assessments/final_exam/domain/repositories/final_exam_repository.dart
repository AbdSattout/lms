import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/final_exam_details_entity.dart';
import '../entities/final_exam_submit_result_entity.dart';

abstract class FinalExamRepository {
  Future<Either<Failure, FinalExamDetailsEntity>> getExam(int courseId);
  Future<Either<Failure, FinalExamSubmitResultEntity>> submit({
    required int courseId,
    required Map<int, int> answers,
  });
}