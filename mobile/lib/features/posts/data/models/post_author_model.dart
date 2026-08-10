import '../../domain/entities/post_author_entity.dart';

class PostAuthorModel extends PostAuthorEntity {
  const PostAuthorModel({
    required super.id,
    required super.name,
    super.picture,
  });

  factory PostAuthorModel.fromJson(Map<String, dynamic> json) {
    return PostAuthorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      picture: json['picture'] as String?,
    );
  }
}