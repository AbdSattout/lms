import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/api_error_resolver.dart';
import '../../../organizations/domain/entities/organization_invite_entity.dart';
import '../../../organizations/domain/usecases/accept_organization_invite_usecase.dart';
import '../../../organizations/domain/usecases/decline_organization_invite_usecase.dart';
import '../../../organizations/domain/usecases/get_my_organization_invites_usecase.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_notification_count_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetMyOrganizationInvitesUseCase getMyOrganizationInvitesUseCase;
  final AcceptOrganizationInviteUseCase acceptOrganizationInviteUseCase;
  final DeclineOrganizationInviteUseCase declineOrganizationInviteUseCase;
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadNotificationCountUseCase getUnreadNotificationCountUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;

  NotificationsBloc({
    required this.getMyOrganizationInvitesUseCase,
    required this.acceptOrganizationInviteUseCase,
    required this.declineOrganizationInviteUseCase,
    required this.getNotificationsUseCase,
    required this.getUnreadNotificationCountUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
  }) : super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_load);
    on<RefreshNotificationsEvent>(_refresh);
    on<AcceptOrganizationInviteEvent>(_acceptInvite);
    on<DeclineOrganizationInviteEvent>(_declineInvite);
    on<MarkNotificationReadEvent>(_markRead);
    on<MarkAllNotificationsReadEvent>(_markAllRead);
  }

  Future<void> _load(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    await _loadData(emit: emit);
  }

  Future<void> _refresh(
    RefreshNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _loadData(emit: emit);
  }

  Future<void> _acceptInvite(
    AcceptOrganizationInviteEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _performInviteAction(
      invite: event.invite,
      emit: emit,
      action: () => acceptOrganizationInviteUseCase(
        slug: event.invite.organization.slug,
        inviteId: event.invite.id,
      ),
      message: 'تم قبول دعوة المنظمة',
    );
  }

  Future<void> _declineInvite(
    DeclineOrganizationInviteEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await _performInviteAction(
      invite: event.invite,
      emit: emit,
      action: () => declineOrganizationInviteUseCase(
        slug: event.invite.organization.slug,
        inviteId: event.invite.id,
      ),
      message: 'تم رفض دعوة المنظمة',
    );
  }

  Future<void> _markRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.notification.read) return;

    final current = state;
    if (current is NotificationsLoaded) {
      emit(
        current.copyWith(
          notifications: _markLocalNotificationRead(
            current.notifications,
            event.notification,
          ),
          unreadCount: current.unreadCount > 0 ? current.unreadCount - 1 : 0,
          clearActionMessage: true,
          clearErrorMessage: true,
        ),
      );
    }

    try {
      await markNotificationReadUseCase(event.notification.id);
      await _loadData(emit: emit);
    } catch (e) {
      _emitActionError(emit, resolveApiErrorMessage(e));
    }
  }

  Future<void> _markAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is NotificationsLoaded && current.unreadCount == 0) return;

    try {
      await markAllNotificationsReadUseCase();
      await _loadData(
        emit: emit,
        actionMessage: 'تم تعليم كل الإشعارات كمقروءة',
      );
    } catch (e) {
      _emitActionError(emit, resolveApiErrorMessage(e));
    }
  }

  Future<void> _performInviteAction({
    required OrganizationInviteEntity invite,
    required Emitter<NotificationsState> emit,
    required Future<void> Function() action,
    required String message,
  }) async {
    final current = state;
    if (current is NotificationsLoaded) {
      emit(
        current.copyWith(
          processingInviteId: invite.id,
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
    required Emitter<NotificationsState> emit,
    String? actionMessage,
  }) async {
    try {
      final results = await Future.wait([
        getMyOrganizationInvitesUseCase(),
        getNotificationsUseCase(),
        getUnreadNotificationCountUseCase(),
      ]);

      emit(
        NotificationsLoaded(
          invites: results[0] as List<OrganizationInviteEntity>,
          notifications: results[1] as List<AppNotificationEntity>,
          unreadCount: results[2] as int,
          actionMessage: actionMessage,
        ),
      );
    } catch (e) {
      final message = resolveApiErrorMessage(e);
      final current = state;
      if (current is NotificationsLoaded) {
        emit(
          current.copyWith(
            clearProcessingInviteId: true,
            errorMessage: message,
            clearActionMessage: true,
          ),
        );
        return;
      }

      emit(NotificationsError(message));
    }
  }

  List<AppNotificationEntity> _markLocalNotificationRead(
    List<AppNotificationEntity> notifications,
    AppNotificationEntity target,
  ) {
    return notifications.map((notification) {
      if (notification.id != target.id) return notification;

      return AppNotificationEntity(
        id: notification.id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        referenceType: notification.referenceType,
        referenceId: notification.referenceId,
        read: true,
        readAt: DateTime.now(),
        createdAt: notification.createdAt,
      );
    }).toList();
  }

  void _emitActionError(Emitter<NotificationsState> emit, String message) {
    final current = state;
    if (current is NotificationsLoaded) {
      emit(
        current.copyWith(
          clearProcessingInviteId: true,
          errorMessage: message,
          clearActionMessage: true,
        ),
      );
      return;
    }

    emit(NotificationsError(message));
  }
}
