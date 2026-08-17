import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/usecases/accept_friend_request_usecase.dart';
import '../../domain/usecases/cancel_friend_request_usecase.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/get_received_friend_requests_usecase.dart';
import '../../domain/usecases/get_sent_friend_requests_usecase.dart';
import '../../domain/usecases/reject_friend_request_usecase.dart';
import '../../domain/usecases/remove_friend_usecase.dart';
import 'friends_event.dart';
import 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final GetFriendsUseCase getFriendsUseCase;
  final GetReceivedFriendRequestsUseCase getReceivedFriendRequestsUseCase;
  final GetSentFriendRequestsUseCase getSentFriendRequestsUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  final CancelFriendRequestUseCase cancelFriendRequestUseCase;
  final RemoveFriendUseCase removeFriendUseCase;

  FriendsBloc({
    required this.getFriendsUseCase,
    required this.getReceivedFriendRequestsUseCase,
    required this.getSentFriendRequestsUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
    required this.cancelFriendRequestUseCase,
    required this.removeFriendUseCase,
  }) : super(FriendsInitial()) {
    on<LoadFriendsEvent>(_load);
    on<RefreshFriendsEvent>(_refresh);
    on<AcceptFriendRequestEvent>(_accept);
    on<RejectFriendRequestEvent>(_reject);
    on<CancelFriendRequestEvent>(_cancel);
    on<RemoveFriendEvent>(_remove);
  }

  Future<void> _load(LoadFriendsEvent event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    await _loadData(emit: emit);
  }

  Future<void> _refresh(
    RefreshFriendsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    await _loadData(emit: emit);
  }

  Future<void> _accept(
    AcceptFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    await _performAction(
      id: event.request.id,
      emit: emit,
      action: () => acceptFriendRequestUseCase(event.request.id),
      message: 'تم قبول طلب الصداقة',
    );
  }

  Future<void> _reject(
    RejectFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    await _performAction(
      id: event.request.id,
      emit: emit,
      action: () => rejectFriendRequestUseCase(event.request.id),
      message: 'تم رفض طلب الصداقة',
    );
  }

  Future<void> _cancel(
    CancelFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    await _performAction(
      id: event.request.id,
      emit: emit,
      action: () => cancelFriendRequestUseCase(event.request.id),
      message: 'تم إلغاء طلب الصداقة',
    );
  }

  Future<void> _remove(
    RemoveFriendEvent event,
    Emitter<FriendsState> emit,
  ) async {
    await _performAction(
      id: event.friend.id,
      emit: emit,
      action: () => removeFriendUseCase(event.friend.id),
      message: 'تمت إزالة الصديق',
    );
  }

  Future<void> _performAction({
    required int id,
    required Emitter<FriendsState> emit,
    required Future<void> Function() action,
    required String message,
  }) async {
    final current = state;
    if (current is FriendsLoaded) {
      emit(
        current.copyWith(
          processingId: id,
          clearActionMessage: true,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      await action();
      await _loadData(emit: emit, actionMessage: message);
    } catch (e) {
      _emitActionError(emit, resolveApiErrorMessage(e));
    }
  }

  Future<void> _loadData({
    required Emitter<FriendsState> emit,
    String? actionMessage,
  }) async {
    try {
      final results = await Future.wait([
        getFriendsUseCase(),
        getReceivedFriendRequestsUseCase(),
        getSentFriendRequestsUseCase(),
      ]);

      emit(
        FriendsLoaded(
          friends: results[0] as List<FriendEntity>,
          receivedRequests: results[1] as List<FriendRequestEntity>,
          sentRequests: results[2] as List<FriendRequestEntity>,
          actionMessage: actionMessage,
        ),
      );
    } catch (e) {
      final message = resolveApiErrorMessage(e);
      final current = state;
      if (current is FriendsLoaded) {
        emit(
          current.copyWith(
            clearProcessingId: true,
            errorMessage: message,
            clearActionMessage: true,
          ),
        );
        return;
      }

      emit(FriendsError(message));
    }
  }

  void _emitActionError(Emitter<FriendsState> emit, String message) {
    final current = state;
    if (current is FriendsLoaded) {
      emit(
        current.copyWith(
          clearProcessingId: true,
          errorMessage: message,
          clearActionMessage: true,
        ),
      );
      return;
    }

    emit(FriendsError(message));
  }
}
