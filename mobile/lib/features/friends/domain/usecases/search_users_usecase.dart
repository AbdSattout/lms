import '../entities/search_user_entity.dart';
import '../repositories/friends_repository.dart';

class SearchUsersUseCase {
  final FriendsRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<SearchUserEntity>> call(String query) {
    return repository.searchUsers(query);
  }
}
