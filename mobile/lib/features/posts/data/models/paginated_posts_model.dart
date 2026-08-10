import '../../domain/entities/paginated_posts_entity.dart';
import 'post_model.dart';

class PaginatedPostsModel extends PaginatedPostsEntity {
  const PaginatedPostsModel({
    required super.content,
    required super.pageNumber,
    required super.pageSize,
    required super.totalElements,
    required super.totalPages,
    required super.first,
    required super.last,
    required super.empty,
  });

  factory PaginatedPostsModel.fromJson(Map<String, dynamic> json) {
    final contentList = (json['content'] as List<dynamic>?)
        ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return PaginatedPostsModel(
      content: contentList,
      pageNumber: json['number'] as int? ?? 0,
      pageSize: json['size'] as int? ?? 20,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      empty: json['empty'] as bool? ?? false,
    );
  }
}