import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/get_sent_friend_requests_usecase.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import 'add_friend_event.dart';
import 'add_friend_state.dart';

class AddFriendBloc extends Bloc<AddFriendEvent, AddFriendState> {
  final SearchUsersUseCase searchUsersUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final GetSentFriendRequestsUseCase getSentFriendRequestsUseCase;

  AddFriendBloc({
    required this.searchUsersUseCase,
    required this.sendFriendRequestUseCase,
    required this.getSentFriendRequestsUseCase,
  }) : super(AddFriendInitial()) {
    on<SearchUsersEvent>(_search);
    on<SendFriendRequestEvent>(_send);
    on<ClearAddFriendEvent>(_clear);
  }

  Future<void> _search(
    SearchUsersEvent event,
    Emitter<AddFriendState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(AddFriendInitial());
      return;
    }

    emit(AddFriendLoading());

    try {
      final results = await searchUsersUseCase(query);
      final sentRequestIds = await _sentReceiverIds();

      emit(AddFriendLoaded(results: results, sentRequestIds: sentRequestIds));
    } catch (e) {
      emit(AddFriendError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _send(
    SendFriendRequestEvent event,
    Emitter<AddFriendState> emit,
  ) async {
    final current = state;
    if (current is AddFriendLoaded) {
      emit(
        current.copyWith(
          processingUserId: event.userId,
          clearActionMessage: true,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      await sendFriendRequestUseCase(event.userId);
      final sentRequestIds = await _sentReceiverIds();

      if (state is AddFriendLoaded) {
        emit(
          (state as AddFriendLoaded).copyWith(
            sentRequestIds: sentRequestIds,
            clearProcessingUserId: true,
            actionMessage: 'تم إرسال طلب الصداقة',
          ),
        );
      }
    } catch (e) {
      if (state is AddFriendLoaded) {
        emit(
          (state as AddFriendLoaded).copyWith(
            clearProcessingUserId: true,
            errorMessage: resolveApiErrorMessage(e),
            clearActionMessage: true,
          ),
        );
        return;
      }

      emit(AddFriendError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _clear(
    ClearAddFriendEvent event,
    Emitter<AddFriendState> emit,
  ) async {
    emit(AddFriendInitial());
  }

  Future<Set<int>> _sentReceiverIds() async {
    final sentRequests = await getSentFriendRequestsUseCase();
    return sentRequests.map((request) => request.receiver.id).toSet();
  }
}
