import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_counts_model.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/like_comment_usecase.dart';
import '../../domain/usecases/unlike_comment_usecase.dart';
import '../../domain/usecases/react_to_post_usecase.dart';

import 'post_details_event.dart';
import 'post_details_state.dart';

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  final GetCommentsUseCase getComments;
  final AddCommentUseCase addComment;
  final DeleteCommentUseCase deleteComment;
  final LikeCommentUseCase likeComment;
  final UnlikeCommentUseCase unlikeComment;
  final ReactToPostUseCase reactToPost;

  PostEntity? _currentPost;
  List<CommentEntity> _comments = [];

  PostDetailsBloc({
    required this.getComments,
    required this.addComment,
    required this.deleteComment,
    required this.likeComment,
    required this.unlikeComment,
    required this.reactToPost,
  }) : super(PostDetailsInitial()) {
    on<LoadComments>(_onLoadComments);
    on<AddCommentRequested>(_onAddComment);
    on<DeleteCommentRequested>(_onDeleteComment);
    on<LikeCommentRequested>(_onLikeComment);
    on<UnlikeCommentRequested>(_onUnlikeComment);
    on<ReactToPostRequested>(_onReactToPost);
  }

  PostEntity? get currentPost => _currentPost;

  Future<void> _onLoadComments(
      LoadComments event,
      Emitter<PostDetailsState> emit,
      ) async {
    _currentPost = event.post;
    emit(CommentsLoading());

    try {
      _comments = await getComments(event.postId);
      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onAddComment(
      AddCommentRequested event,
      Emitter<PostDetailsState> emit,
      ) async {
    try {
      await addComment(event.postId, event.content, parentCommentId: event.parentCommentId);
      _comments = await getComments(event.postId);

      // Update comment count on the post
      if (_currentPost is PostModel) {
        _currentPost = (_currentPost as PostModel).copyWith(
          commentCount: _currentPost!.commentCount + 1,
        );
      }

      emit(CommentAdded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onDeleteComment(
      DeleteCommentRequested event,
      Emitter<PostDetailsState> emit,
      ) async {
    try {
      await deleteComment(event.postId, event.commentId);
      _comments = await getComments(event.postId);

      if (_currentPost is PostModel) {
        _currentPost = (_currentPost as PostModel).copyWith(
          commentCount: (_currentPost!.commentCount - 1).clamp(0, 999999),
        );
      }

      emit(CommentDeleted(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onLikeComment(
      LikeCommentRequested event,
      Emitter<PostDetailsState> emit,
      ) async {
    try {
      await likeComment(event.commentId);
      _comments = await getComments(_currentPost!.id);
      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onUnlikeComment(
      UnlikeCommentRequested event,
      Emitter<PostDetailsState> emit,
      ) async {
    try {
      await unlikeComment(event.commentId);
      _comments = await getComments(_currentPost!.id);
      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onReactToPost(
      ReactToPostRequested event,
      Emitter<PostDetailsState> emit,
      ) async {
    try {
      await reactToPost(event.postId, event.reactionType);

      // Refresh comments to keep them visible
      _comments = await getComments(_currentPost!.id);

      // Update reaction counts locally
      final updatedReactions = ReactionCountsModel(
        like: _currentPost!.reactionCounts.like + (event.reactionType == 'LIKE' ? 1 : 0),
        love: _currentPost!.reactionCounts.love + (event.reactionType == 'LOVE' ? 1 : 0),
        support: _currentPost!.reactionCounts.support + (event.reactionType == 'SUPPORT' ? 1 : 0),
        celebrate: _currentPost!.reactionCounts.celebrate + (event.reactionType == 'CELEBRATE' ? 1 : 0),
        insightful: _currentPost!.reactionCounts.insightful + (event.reactionType == 'INSIGHTFUL' ? 1 : 0),
      );

      if (_currentPost is PostModel) {
        _currentPost = (_currentPost as PostModel).copyWith(reactionCounts: updatedReactions);
      }

      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }
}