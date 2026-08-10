abstract class PostsEvent {}

class LoadOrganizationPosts extends PostsEvent {
  final String orgSlug;
  LoadOrganizationPosts(this.orgSlug);
}

class LoadCoursePosts extends PostsEvent {
  final String courseSlug;
  LoadCoursePosts(this.courseSlug);
}

class RefreshPosts extends PostsEvent {}