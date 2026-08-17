import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/accept_friend_request_usecase.dart';
import '../../domain/usecases/cancel_friend_request_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/reject_friend_request_usecase.dart';
import '../../domain/usecases/remove_friend_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  final CancelFriendRequestUseCase cancelFriendRequestUseCase;
  final RemoveFriendUseCase removeFriendUseCase;

  int? _currentUserId;

  UserProfileBloc({
    required this.getUserProfileUseCase,
    required this.sendFriendRequestUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
    required this.cancelFriendRequestUseCase,
    required this.removeFriendUseCase,
  }) : super(UserProfileInitial()) {
    on<LoadUserProfileEvent>(_load);
    on<SendFriendRequestEvent>(_sendRequest);
    on<AcceptFriendRequestEvent>(_acceptRequest);
    on<RejectFriendRequestEvent>(_rejectRequest);
    on<CancelFriendRequestEvent>(_cancelRequest);
    on<RemoveFriendEvent>(_removeFriend);
  }

  Future<void> _load(
    LoadUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(UserProfileLoading());
    await _loadProfile(emit: emit, userId: event.userId);
  }

  Future<void> _sendRequest(
    SendFriendRequestEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    await _performAction(
      id: event.userId,
      emit: emit,
      action: () => sendFriendRequestUseCase(event.userId),
      message: 'تم إرسال طلب الصداقة',
    );
  }

  Future<void> _acceptRequest(
    AcceptFriendRequestEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    await _performAction(
      id: event.requestId,
      emit: emit,
      action: () => acceptFriendRequestUseCase(event.requestId),
      message: 'تم قبول طلب الصداقة',
    );
  }

  Future<void> _rejectRequest(
    RejectFriendRequestEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    await _performAction(
      id: event.requestId,
      emit: emit,
      action: () => rejectFriendRequestUseCase(event.requestId),
      message: 'تم رفض طلب الصداقة',
    );
  }

  Future<void> _cancelRequest(
    CancelFriendRequestEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    await _performAction(
      id: event.requestId,
      emit: emit,
      action: () => cancelFriendRequestUseCase(event.requestId),
      message: 'تم إلغاء طلب الصداقة',
    );
  }

  Future<void> _removeFriend(
    RemoveFriendEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    await _performAction(
      id: event.friendId,
      emit: emit,
      action: () => removeFriendUseCase(event.friendId),
      message: 'تمت إزالة الصديق',
    );
  }

  Future<void> _performAction({
    required int id,
    required Emitter<UserProfileState> emit,
    required Future<void> Function() action,
    required String message,
  }) async {
    final current = state;
    if (current is UserProfileLoaded) {
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
      final userId = _currentUserId;
      if (userId == null) return;
      await _loadProfile(emit: emit, userId: userId, actionMessage: message);
    } catch (e) {
      _emitActionError(emit, resolveApiErrorMessage(e));
    }
  }

  Future<void> _loadProfile({
    required Emitter<UserProfileState> emit,
    required int userId,
    String? actionMessage,
  }) async {
    try {
      final profile = await getUserProfileUseCase(userId);

      emit(UserProfileLoaded(profile: profile, actionMessage: actionMessage));
    } catch (e) {
      final message = resolveApiErrorMessage(e);
      final current = state;
      if (current is UserProfileLoaded) {
        emit(
          current.copyWith(
            clearProcessingId: true,
            errorMessage: message,
            clearActionMessage: true,
          ),
        );
        return;
      }

      emit(UserProfileError(message));
    }
  }

  void _emitActionError(Emitter<UserProfileState> emit, String message) {
    final current = state;
    if (current is UserProfileLoaded) {
      emit(
        current.copyWith(
          clearProcessingId: true,
          errorMessage: message,
          clearActionMessage: true,
        ),
      );
      return;
    }

    emit(UserProfileError(message));
  }
}
