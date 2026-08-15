class SearchUserEntity {
  final int id;
  final String name;
  final String? username;
  final String? picture;
  final String? email;

  const SearchUserEntity({
    required this.id,
    required this.name,
    this.username,
    this.picture,
    this.email,
  });
}
