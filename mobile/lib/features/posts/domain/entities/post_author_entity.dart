class PostAuthorEntity {
  final int id;
  final String name;
  final String? picture;

  const PostAuthorEntity({
    required this.id,
    required this.name,
    this.picture,
  });
}