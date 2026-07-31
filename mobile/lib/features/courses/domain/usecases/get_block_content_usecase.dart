import '../entities/block_content_entity.dart';
import '../repositories/block_repository.dart';

class GetBlockContentUseCase {
  final BlockRepository repository;
  GetBlockContentUseCase(this.repository);

  Future<BlockContentEntity> call(int blockId) {
    return repository.getBlockContent(blockId);
  }
}