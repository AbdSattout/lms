import '../../domain/entities/block_content_entity.dart';
import '../../domain/repositories/block_repository.dart';
import '../datasources/block_remote_datasource.dart';

class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDataSource remote;
  BlockRepositoryImpl(this.remote);

  @override
  Future<BlockContentEntity> getBlockContent(int blockId) {
    return remote.getBlockContent(blockId);
  }

  @override
  Future<BlockAnswerResultEntity> submitAnswer({
    required int blockId,
    required int answerIndex,
  }) {
    return remote.submitAnswer(blockId: blockId, answerIndex: answerIndex);
  }
}