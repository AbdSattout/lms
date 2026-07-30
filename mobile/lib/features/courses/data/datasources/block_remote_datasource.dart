import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../models/block_content_model.dart';

abstract class BlockRemoteDataSource {
  Future<BlockContentModel> getBlockContent(int blockId);

  Future<BlockAnswerResultModel> submitAnswer({
    required int blockId,
    required int answerIndex,
  });
}

class BlockRemoteDataSourceImpl implements BlockRemoteDataSource {
  final ApiConsumer api;
  BlockRemoteDataSourceImpl(this.api);

  @override
  Future<BlockContentModel> getBlockContent(int blockId) async {
    final response = await api.get(EndPoints.blockContent(blockId));
    return BlockContentModel.fromJson(response);
  }

  @override
  Future<BlockAnswerResultModel> submitAnswer({
    required int blockId,
    required int answerIndex,
  }) async {
    final response = await api.post(
      EndPoints.submitBlockAnswer(blockId),
      data: {'answerIndex': answerIndex},
    );
    return BlockAnswerResultModel.fromJson(response);
  }
}