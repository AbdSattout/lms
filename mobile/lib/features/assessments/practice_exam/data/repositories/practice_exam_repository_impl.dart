import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/practice_exam_summary_entity.dart';
import '../../domain/entities/practice_exam_details_entity.dart';
import '../../domain/entities/practice_exam_submit_result_entity.dart';
import '../../domain/repositories/practice_exam_repository.dart';
import '../datasources/practice_exam_remote_datasource.dart';

class PracticeExamRepositoryImpl implements PracticeExamRepository {
  final PracticeExamRemoteDataSource remoteDataSource;

  PracticeExamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PracticeExamSummaryEntity>>> getList(int courseId) async {
    try {
      final list = await remoteDataSource.getList(courseId);
      return Right(list);
    } on TooManyRequestsException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    }on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PracticeExamDetailsEntity>> getDetails({
    required int courseId,
    required int examId,
  }) async {
    try {
      final details = await remoteDataSource.getDetails(courseId: courseId, examId: examId);
      return Right(details);
    } on TooManyRequestsException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    }on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PracticeExamSubmitResultEntity>> submit({
    required int courseId,
    required int examId,
    required int attemptId,
    required Map<int, int> answers,
  }) async {
    try {
      final result = await remoteDataSource.submit(
        courseId: courseId,
        examId: examId,
        attemptId: attemptId,
        answers: answers,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}