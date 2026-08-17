import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/random_quiz_session_entity.dart';
import '../entities/random_quiz_session_entity.dart';
import '../entities/random_quiz_submit_result_entity.dart';

abstract class RandomQuizRepository {
  Future<Either<Failure, RandomQuizSessionEntity>> generate({
    required int courseId,
    required String difficulty,
    required int count,
  });

  Future<Either<Failure, RandomQuizSubmitResultEntity>> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  });
}