import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/chat_updates_notifier.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatsState> {
  final GetConversationsUseCase getConversationsUseCase;
  final ChatUpdatesNotifier chatUpdatesNotifier;

  StreamSubscription<void>? _updatesSubscription;

  ChatBloc({
    required this.getConversationsUseCase,
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
      emit(
        ChatsLoaded(
          conversations: page.content,
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
}