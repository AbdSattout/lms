import 'package:dartz/dartz.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/ai_quiz_session_entity.dart';
import '../../domain/entities/ai_quiz_submit_result_entity.dart';
import '../../domain/repositories/ai_quiz_repository.dart';
import '../datasources/ai_quiz_remote_datasource.dart';

class AiQuizRepositoryImpl implements AiQuizRepository {
  final AiQuizRemoteDataSource remoteDataSource;

  AiQuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AiQuizSessionEntity>> generate(int courseId) async {
    try {
      final session = await remoteDataSource.generate(courseId);
      return Right(session);
    } on TooManyRequestsException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    }on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiQuizSubmitResultEntity>> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  }) async {
    try {
      final result = await remoteDataSource.submit(
        courseId: courseId,
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