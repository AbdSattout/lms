import '../entities/block_content_entity.dart';
import '../repositories/block_repository.dart';

class SubmitBlockAnswerUseCase {
  final BlockRepository repository;
  SubmitBlockAnswerUseCase(this.repository);

  Future<BlockAnswerResultEntity> call({
    required int blockId,
    required int answerIndex,
  }) {
    return repository.submitAnswer(blockId: blockId, answerIndex: answerIndex);
  }
}