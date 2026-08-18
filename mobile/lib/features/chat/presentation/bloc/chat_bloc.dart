import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/chat_updates_notifier.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../../friends/domain/entities/friend_user_entity.dart';
import '../../../friends/domain/usecases/get_friends_usecase.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatsState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetFriendsUseCase getFriendsUseCase;
  final ChatUpdatesNotifier chatUpdatesNotifier;

  StreamSubscription<void>? _updatesSubscription;

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getFriendsUseCase,
    required this.chatUpdatesNotifier,
  }) : super(ChatsInitial()) {
    on<LoadChatsEvent>(_load);
    on<RefreshChatsEvent>(_refresh);
    on<LoadMoreChatsEvent>(_loadMore);

    _updatesSubscription = chatUpdatesNotifier.updates.listen((_) {
      if (!isClosed) add(RefreshChatsEvent());
    });
  }

  @override
  Future<void> close() {
    _updatesSubscription?.cancel();
    return super.close();
  }

  Future<void> _load(LoadChatsEvent event, Emitter<ChatsState> emit) async {
    emit(ChatsLoading());
    await _fetch(emit: emit);
  }

  Future<void> _refresh(
    RefreshChatsEvent event,
    Emitter<ChatsState> emit,
  ) async {
    if (state is ChatsInitial || state is ChatsError) {
      emit(ChatsLoading());
    }
    await _fetch(emit: emit);
  }

  Future<void> _fetch({required Emitter<ChatsState> emit}) async {
    try {
      final page = await getConversationsUseCase(page: 0);
      final users = await _resolveUsers(page.content);
      emit(
        ChatsLoaded(
          conversations: page.content,
          users: users,
          hasMore: !page.last,
          pageNumber: 0,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      final message = resolveApiErrorMessage(e);
      final current = state;
      if (current is ChatsLoaded) {
        emit(current.copyWith(errorMessage: message, clearActionMessage: true));
        return;
      }
      emit(ChatsError(message));
    }
  }

  Future<void> _loadMore(
    LoadMoreChatsEvent event,
    Emitter<ChatsState> emit,
  ) async {
    final current = state;
    if (current is! ChatsLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await getConversationsUseCase(page: current.pageNumber + 1);
      emit(
        current.copyWith(
          conversations: [...current.conversations, ...page.content],
          hasMore: !page.last,
          pageNumber: current.pageNumber + 1,
          isLoadingMore: false,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoadingMore: false,
          errorMessage: resolveApiErrorMessage(e),
          clearActionMessage: true,
        ),
      );
    }
  }

  Future<Map<int, FriendUserEntity>> _resolveUsers(
    List<ConversationEntity> conversations,
  ) async {
    try {
      final friends = await getFriendsUseCase();
      return {for (final friend in friends) friend.user.id: friend.user};
    } catch (e) {
      return const {};
    }
  }
}
