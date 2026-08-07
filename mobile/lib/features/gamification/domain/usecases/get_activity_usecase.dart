import '../entities/activity_entity.dart';
import '../repositories/gamification_repository.dart';

class GetActivityUseCase {
  final GamificationRepository repository;
  GetActivityUseCase(this.repository);
  Future<List<ActivityEntity>> call({String? from, String? to}) =>
      repository.getActivity(from: from, to: to);
}