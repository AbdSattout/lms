class FriendUserEntity {
  final int id;
  final String name;
  final String? username;
  final String? picture;

  const FriendUserEntity({
    required this.id,
    required this.name,
    this.username,
    this.picture,
  });
}
