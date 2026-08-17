import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/final_exam_details_entity.dart';
import '../../domain/entities/final_exam_submit_result_entity.dart';
import '../../domain/repositories/final_exam_repository.dart';
import '../datasources/final_exam_remote_datasource.dart';

class FinalExamRepositoryImpl implements FinalExamRepository {
  final FinalExamRemoteDataSource remoteDataSource;

  FinalExamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FinalExamDetailsEntity>> getExam(int courseId) async {
    try {
      final exam = await remoteDataSource.getExam(courseId);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FinalExamSubmitResultEntity>> submit({
    required int courseId,
    required Map<int, int> answers,
  }) async {
    try {
      final result = await remoteDataSource.submit(courseId: courseId, answers: answers);
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}