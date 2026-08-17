import '../entities/user_profile_entity.dart';
import '../repositories/friends_repository.dart';

class GetUserProfileUseCase {
  final FriendsRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<UserProfileEntity> call(int userId) {
    return repository.getUserProfile(userId);
  }
}
