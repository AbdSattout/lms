import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/accept_organization_invite_by_token_usecase.dart';
import 'public_organization_invite_event.dart';
import 'public_organization_invite_state.dart';

class PublicOrganizationInviteBloc
    extends Bloc<PublicOrganizationInviteEvent, PublicOrganizationInviteState> {
  final AcceptOrganizationInviteByTokenUseCase acceptInviteByTokenUseCase;

  PublicOrganizationInviteBloc({required this.acceptInviteByTokenUseCase})
    : super(const PublicOrganizationInviteState.initial()) {
    on<AcceptPublicOrganizationInviteEvent>(_accept);
    on<ResetPublicOrganizationInviteEvent>(
      (_, emit) => emit(const PublicOrganizationInviteState.initial()),
    );
  }

  Future<void> _accept(
    AcceptPublicOrganizationInviteEvent event,
    Emitter<PublicOrganizationInviteState> emit,
  ) async {
    final token = event.token.trim();
    if (token.isEmpty) {
      emit(
        state.copyWith(
          status: PublicOrganizationInviteStatus.error,
          message: 'رابط الدعوة غير صالح',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PublicOrganizationInviteStatus.accepting,
        clearMessage: true,
      ),
    );

    try {
      await acceptInviteByTokenUseCase(token);
      emit(
        state.copyWith(
          status: PublicOrganizationInviteStatus.accepted,
          message: 'تم قبول الدعوة بنجاح',
        ),
      );
    } catch (error) {
      final message = resolveApiErrorMessage(error);
      if (_isAlreadyMemberMessage(message)) {
        emit(
          state.copyWith(
            status: PublicOrganizationInviteStatus.accepted,
            message: 'أنت عضو في هذه المنظمة بالفعل',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: PublicOrganizationInviteStatus.error,
          message: message,
        ),
      );
    }
  }

  bool _isAlreadyMemberMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('already a member') ||
        normalized.contains('already member');
  }
}
