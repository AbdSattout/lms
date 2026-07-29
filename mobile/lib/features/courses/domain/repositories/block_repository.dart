import '../entities/block_content_entity.dart';

abstract class BlockRepository {
  Future<BlockContentEntity> getBlockContent(int blockId);

  Future<BlockAnswerResultEntity> submitAnswer({
    required int blockId,
    required int answerIndex,
  });
}