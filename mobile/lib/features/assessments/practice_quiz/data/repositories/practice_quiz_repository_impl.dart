import 'package:dartz/dartz.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/practice_quiz_summary_entity.dart';
import '../../domain/entities/practice_quiz_details_entity.dart';
import '../../domain/entities/practice_quiz_submit_result_entity.dart';
import '../../domain/repositories/practice_quiz_repository.dart';
import '../datasources/practice_quiz_remote_datasource.dart';

class PracticeQuizRepositoryImpl implements PracticeQuizRepository {
  final PracticeQuizRemoteDataSource remoteDataSource;

  PracticeQuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PracticeQuizSummaryEntity>>> getList(int courseId) async {
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
  Future<Either<Failure, PracticeQuizDetailsEntity>> getDetails({
    required int courseId,
    required int quizId,
  }) async {
    try {
      final details = await remoteDataSource.getDetails(courseId: courseId, quizId: quizId);
      return Right(details);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PracticeQuizSubmitResultEntity>> submit({
    required int courseId,
    required int quizId,
    required Map<int, int> answers,
  }) async {
    try {
      final result = await remoteDataSource.submit(
        courseId: courseId,
        quizId: quizId,
        answers: answers,
      );
      return Right(result);
    } on TooManyRequestsException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    }on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }
}