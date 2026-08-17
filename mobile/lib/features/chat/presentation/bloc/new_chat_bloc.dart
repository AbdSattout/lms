import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../../friends/domain/usecases/get_friends_usecase.dart';
import 'new_chat_event.dart';
import 'new_chat_state.dart';

class NewChatBloc extends Bloc<NewChatEvent, NewChatState> {
  final GetFriendsUseCase getFriendsUseCase;

  NewChatBloc({required this.getFriendsUseCase}) : super(NewChatInitial()) {
    on<LoadNewChatFriendsEvent>(_load);
  }

  Future<void> _load(
    LoadNewChatFriendsEvent event,
    Emitter<NewChatState> emit,
  ) async {
    emit(NewChatLoading());
    try {
      final friends = await getFriendsUseCase();
      emit(NewChatLoaded(friends.map((f) => f.user).toList()));
    } catch (e) {
      emit(NewChatError(resolveApiErrorMessage(e)));
    }
  }
}
