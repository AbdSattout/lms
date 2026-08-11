import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_organization_posts_usecase.dart';
import '../../domain/usecases/get_course_posts_usecase.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetOrganizationPostsUseCase getOrganizationPosts;
  final GetCoursePostsUseCase getCoursePosts;

  String? _lastOrgSlug;
  String? _lastCourseSlug;
  bool _isOrgContext = false;

  PostsBloc({
    required this.getOrganizationPosts,
    required this.getCoursePosts,
  }) : super(PostsInitial()) {
    on<LoadOrganizationPosts>(_onLoadOrganizationPosts);
    on<LoadCoursePosts>(_onLoadCoursePosts);
    on<RefreshPosts>(_onRefresh);
    on<UpdatePostInList>(_onUpdatePostInList);
  }

  Future<void> _onLoadOrganizationPosts(
      LoadOrganizationPosts event,
      Emitter<PostsState> emit,
      ) async {
    try {
      emit(PostsLoading());
      _isOrgContext = true;
      _lastOrgSlug = event.orgSlug;
      final result = await getOrganizationPosts(event.orgSlug);
      emit(PostsLoaded(posts: result.content, isLastPage: result.last));
    } catch (e) {
      emit(PostsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onLoadCoursePosts(
      LoadCoursePosts event,
      Emitter<PostsState> emit,
      ) async {
    try {
      emit(PostsLoading());
      _isOrgContext = false;
      _lastCourseSlug = event.courseSlug;
      final result = await getCoursePosts(event.courseSlug);
      emit(PostsLoaded(posts: result.content, isLastPage: result.last));
    } catch (e) {
      emit(PostsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onRefresh(
      RefreshPosts event,
      Emitter<PostsState> emit,
      ) async {
    if (_isOrgContext && _lastOrgSlug != null) {
      add(LoadOrganizationPosts(_lastOrgSlug!));
    } else if (_lastCourseSlug != null) {
      add(LoadCoursePosts(_lastCourseSlug!));
    }
  }

  void _onUpdatePostInList(
      UpdatePostInList event,
      Emitter<PostsState> emit,
      ) {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;
      final updatedPosts = currentState.posts.map((p) {
        return p.id == event.updatedPost.id ? event.updatedPost : p;
      }).toList();
      emit(PostsLoaded(posts: updatedPosts, isLastPage: currentState.isLastPage));
    }
  }
}