abstract class PostsEvent {}

class LoadOrganizationPosts extends PostsEvent {
  final String orgSlug;
  LoadOrganizationPosts(this.orgSlug);
}

class LoadCoursePosts extends PostsEvent {
  final int courseId;
  LoadCoursePosts(this.courseId);
}

class RefreshPosts extends PostsEvent {}
