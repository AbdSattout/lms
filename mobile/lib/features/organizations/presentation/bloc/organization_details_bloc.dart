import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../domain/usecases/accept_organization_invite_usecase.dart';
import '../../domain/usecases/cancel_join_request_usecase.dart';
import '../../domain/usecases/delete_organization_usecase.dart';
import '../../domain/usecases/get_organization_by_slug_usecase.dart';
import '../../domain/usecases/join_organization_usecase.dart';
import '../../domain/usecases/leave_organization_usecase.dart';
import 'organization_details_event.dart';
import 'organization_details_state.dart';

class OrganizationDetailsBloc
    extends Bloc<OrganizationDetailsEvent, OrganizationDetailsState> {
  final GetOrganizationBySlugUseCase getOrganizationBySlugUseCase;
  final JoinOrganizationUseCase joinOrganizationUseCase;
  final LeaveOrganizationUseCase leaveOrganizationUseCase;
  final CancelJoinRequestUseCase cancelJoinRequestUseCase;
  final AcceptOrganizationInviteUseCase acceptOrganizationInviteUseCase;
  final DeleteOrganizationUseCase deleteOrganizationUseCase;

  OrganizationDetailsBloc({
    required this.getOrganizationBySlugUseCase,
    required this.joinOrganizationUseCase,
    required this.leaveOrganizationUseCase,
    required this.cancelJoinRequestUseCase,
    required this.acceptOrganizationInviteUseCase,
    required this.deleteOrganizationUseCase,
  }) : super(OrganizationDetailsInitial()) {
    on<GetOrganizationDetailsEvent>(_getDetails);
    on<JoinOrganizationEvent>(_join);
    on<LeaveOrganizationEvent>(_leave);
    on<CancelJoinRequestEvent>(_cancel);
    on<AcceptOrganizationDetailsInviteEvent>(_acceptInvite);
    on<DeleteOrganizationEvent>(_delete);
  }

  Future<void> _getDetails(
    GetOrganizationDetailsEvent event,
    Emitter<OrganizationDetailsState> emit,
  ) async {
    try {
      emit(OrganizationDetailsLoading());
      final organization = await getOrganizationBySlugUseCase(event.slug);
      emit(OrganizationDetailsLoaded(organization));
    } catch (e) {
      emit(OrganizationDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _join(
    JoinOrganizationEvent event,
    Emitter<OrganizationDetailsState> emit,
  ) => _performAction(
    emit: emit,
    slug: event.slug,
    action: () => joinOrganizationUseCase(event.slug),
  );

  Future<void> _leave(
    LeaveOrganizationEvent event,
    Emitter<OrganizationDetailsState> emit,
  ) => _performAction(
    emit: emit,
    slug: event.slug,
    action: () => leaveOrganizationUseCase(event.slug),
  );

  Future<void> _cancel(
    CancelJoinRequestEvent event,
    Emitter<OrganizationDetailsState> emit,
  ) => _performAction(
    emit: emit,
    slug: event.slug,
    action: () => cancelJoinRequestUseCase(event.slug),
  );

  Future<void> _acceptInvite(
    AcceptOrganizationDetailsInviteEvent event,
    Emitter<OrganizationDetailsState> emit,
  ) => _performAction(
    emit: emit,
    slug: event.slug,
    action: () => acceptOrganizationInviteUseCase(
      slug: event.slug,
      inviteId: event.inviteId,
    ),
  );

  Future<void> _delete(
    DeleteOrganizationEvent event,
    Emitter<OrganizationDetailsState> emit,
  ) async {
    final current = state;
    if (current is OrganizationDetailsLoaded) {
      emit(OrganizationDetailsLoaded(current.organization, isProcessing: true));
    }

    try {
      await deleteOrganizationUseCase(event.slug);
      emit(OrganizationDeleted());
    } catch (e) {
      emit(OrganizationDetailsError(resolveApiErrorMessage(e)));
    }
  }

  Future<void> _performAction({
    required Emitter<OrganizationDetailsState> emit,
    required String slug,
    required Future<void> Function() action,
  }) async {
    final current = state;
    if (current is OrganizationDetailsLoaded) {
      emit(OrganizationDetailsLoaded(current.organization, isProcessing: true));
    }

    try {
      await action();
      final organization = await getOrganizationBySlugUseCase(slug);
      emit(OrganizationDetailsLoaded(organization));
    } catch (e) {
      emit(OrganizationDetailsError(resolveApiErrorMessage(e)));
    }
  }
}
