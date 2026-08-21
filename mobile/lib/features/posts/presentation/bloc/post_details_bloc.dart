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
    on<ToggleCommentLike>(_onToggleCommentLike);
    on<TogglePostReaction>(_onTogglePostReaction);
  }

  PostEntity? get currentPost => _currentPost;

  Future<void> _onLoadComments(LoadComments event, Emitter<PostDetailsState> emit) async {
    _currentPost = event.post;
    emit(CommentsLoading());
    try {
      _comments = await getComments(event.postId);
      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onAddComment(AddCommentRequested event, Emitter<PostDetailsState> emit) async {
    emit(CommentSubmitting(comments: _comments, post: _currentPost!));

    try {
      await addComment(event.postId, event.content, parentCommentId: event.parentCommentId);
      _comments = await getComments(event.postId);
      if (_currentPost is PostModel) {
        _currentPost = (_currentPost as PostModel).copyWith(commentCount: _currentPost!.commentCount + 1);
      }
      emit(CommentAdded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }
  Future<void> _onDeleteComment(DeleteCommentRequested event, Emitter<PostDetailsState> emit) async {
    try {
      await deleteComment(event.commentId);
      _comments = await getComments(_currentPost!.id);
      if (_currentPost is PostModel) {
        _currentPost = (_currentPost as PostModel).copyWith(commentCount: (_currentPost!.commentCount - 1).clamp(0, 999999));
      }
      emit(CommentDeleted(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onToggleCommentLike(ToggleCommentLike event, Emitter<PostDetailsState> emit) async {
    try {
      final comment = _comments.firstWhere((c) => c.id == event.commentId);
      if (comment.viewerReaction != null) {
        await unlikeComment(event.commentId);
      } else {
        await likeComment(event.commentId);
      }
      _comments = await getComments(_currentPost!.id);
      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _onTogglePostReaction(TogglePostReaction event, Emitter<PostDetailsState> emit) async {
    try {
      await reactToPost(event.postId, event.reactionType);
      _comments = await getComments(_currentPost!.id);

      String? newViewerReaction;
      final oldReaction = _currentPost?.viewerReaction;
      final isRemoving = oldReaction == event.reactionType;

      if (isRemoving) {
        newViewerReaction = null;
      } else {
        newViewerReaction = event.reactionType;
      }

      final oldCounts = _currentPost!.reactionCounts;
      ReactionCountsModel newCounts = ReactionCountsModel(
        like: oldCounts.like,
        love: oldCounts.love,
        support: oldCounts.support,
        celebrate: oldCounts.celebrate,
        insightful: oldCounts.insightful,
      );

      if (oldReaction != null) {
        newCounts = _decrementReaction(newCounts, oldReaction);
      }

      if (!isRemoving) {
        newCounts = _incrementReaction(newCounts, event.reactionType);
      }

      if (_currentPost is PostModel) {
        _currentPost = (_currentPost as PostModel).copyWith(
          viewerReaction: newViewerReaction,
          clearViewerReaction: isRemoving,
          reactionCounts: newCounts,
        );
      }

      emit(CommentsLoaded(comments: _comments, post: _currentPost!));
    } catch (e) {
      emit(PostDetailsError(resolveApiErrorMessage(e)));
    }
  }

  ReactionCountsModel _incrementReaction(ReactionCountsModel counts, String type) {
    switch (type) {
      case 'LIKE': return ReactionCountsModel(like: counts.like + 1, love: counts.love, support: counts.support, celebrate: counts.celebrate, insightful: counts.insightful);
      case 'LOVE': return ReactionCountsModel(like: counts.like, love: counts.love + 1, support: counts.support, celebrate: counts.celebrate, insightful: counts.insightful);
      case 'SUPPORT': return ReactionCountsModel(like: counts.like, love: counts.love, support: counts.support + 1, celebrate: counts.celebrate, insightful: counts.insightful);
      case 'CELEBRATE': return ReactionCountsModel(like: counts.like, love: counts.love, support: counts.support, celebrate: counts.celebrate + 1, insightful: counts.insightful);
      case 'INSIGHTFUL': return ReactionCountsModel(like: counts.like, love: counts.love, support: counts.support, celebrate: counts.celebrate, insightful: counts.insightful + 1);
      default: return counts;
    }
  }

  ReactionCountsModel _decrementReaction(ReactionCountsModel counts, String type) {
    switch (type) {
      case 'LIKE': return ReactionCountsModel(like: (counts.like - 1).clamp(0, 999999), love: counts.love, support: counts.support, celebrate: counts.celebrate, insightful: counts.insightful);
      case 'LOVE': return ReactionCountsModel(like: counts.like, love: (counts.love - 1).clamp(0, 999999), support: counts.support, celebrate: counts.celebrate, insightful: counts.insightful);
      case 'SUPPORT': return ReactionCountsModel(like: counts.like, love: counts.love, support: (counts.support - 1).clamp(0, 999999), celebrate: counts.celebrate, insightful: counts.insightful);
      case 'CELEBRATE': return ReactionCountsModel(like: counts.like, love: counts.love, support: counts.support, celebrate: (counts.celebrate - 1).clamp(0, 999999), insightful: counts.insightful);
      case 'INSIGHTFUL': return ReactionCountsModel(like: counts.like, love: counts.love, support: counts.support, celebrate: counts.celebrate, insightful: (counts.insightful - 1).clamp(0, 999999));
      default: return counts;
    }
  }
}