import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failure.dart';
import '../entities/ai_quiz_session_entity.dart';
import '../entities/ai_quiz_submit_result_entity.dart';

abstract class AiQuizRepository {
  Future<Either<Failure, AiQuizSessionEntity>> generate(int courseId);
  Future<Either<Failure, AiQuizSubmitResultEntity>> submit({
    required int courseId,
    required int attemptId,
    required Map<int, int> answers,
  });
}