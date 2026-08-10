import '../../domain/entities/post_entity.dart';

abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<PostEntity> posts;
  final bool isLastPage;
  PostsLoaded({required this.posts, required this.isLastPage});
}

class PostsError extends PostsState {
  final String message;
  PostsError(this.message);
}