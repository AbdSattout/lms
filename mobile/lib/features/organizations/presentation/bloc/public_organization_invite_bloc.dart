import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/accept_organization_invite_by_token_usecase.dart';
import '../../domain/usecases/get_organization_invite_preview_by_token_usecase.dart';
import 'public_organization_invite_event.dart';
import 'public_organization_invite_state.dart';

class PublicOrganizationInviteBloc
    extends Bloc<PublicOrganizationInviteEvent, PublicOrganizationInviteState> {
  final AcceptOrganizationInviteByTokenUseCase acceptInviteByTokenUseCase;
  final GetOrganizationInvitePreviewByTokenUseCase
  getInvitePreviewByTokenUseCase;

  PublicOrganizationInviteBloc({
    required this.acceptInviteByTokenUseCase,
    required this.getInvitePreviewByTokenUseCase,
  }) : super(const PublicOrganizationInviteState.initial()) {
    on<PreviewPublicOrganizationInviteEvent>(_preview);
    on<AcceptPublicOrganizationInviteEvent>(_accept);
    on<ResetPublicOrganizationInviteEvent>(
      (_, emit) => emit(const PublicOrganizationInviteState.initial()),
    );
  }

  Future<void> _preview(
    PreviewPublicOrganizationInviteEvent event,
    Emitter<PublicOrganizationInviteState> emit,
  ) async {
    final token = event.token.trim();
    if (token.isEmpty) {
      emit(
        state.copyWith(
          status: PublicOrganizationInviteStatus.error,
          message: 'رابط الدعوة غير صالح',
          clearInvite: true,
          clearToken: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PublicOrganizationInviteStatus.previewing,
        token: token,
        clearMessage: true,
        clearInvite: true,
      ),
    );

    try {
      final invite = await getInvitePreviewByTokenUseCase(token);
      final alreadyJoined = invite.alreadyJoined;
      emit(
        state.copyWith(
          status: PublicOrganizationInviteStatus.previewed,
          invite: invite,
          token: token,
          message: alreadyJoined ? 'أنت عضو في هذه المنظمة بالفعل' : null,
          clearMessage: !alreadyJoined,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: PublicOrganizationInviteStatus.error,
          message: resolveApiErrorMessage(error),
          token: token,
          clearInvite: true,
        ),
      );
    }
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
        token: token,
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
