import 'package:dartz/dartz.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../../domain/entities/random_quiz_session_entity.dart';
import '../../domain/entities/random_quiz_submit_result_entity.dart';
import '../../domain/repositories/random_quiz_repository.dart';
import '../datasources/random_quiz_remote_datasource.dart';

class RandomQuizRepositoryImpl implements RandomQuizRepository {
  final RandomQuizRemoteDataSource remoteDataSource;

  RandomQuizRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RandomQuizSessionEntity>> generate({
    required int courseId,
    required String difficulty,
    required int count,
  }) async {
    try {
      final session = await remoteDataSource.generate(
        courseId: courseId,
        difficulty: difficulty,
        count: count,
      );
      return Right(session);
    } on ServerException catch (e) {
      return Left(Failure(errMessage: e.errorModel.errorMessage));
    } catch (e) {
      return Left(Failure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RandomQuizSubmitResultEntity>> submit({
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