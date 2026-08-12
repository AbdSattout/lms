import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/external_url_launcher.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/injection_container.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/immersive_mode_guard.dart';

import 'features/auth/domain/entities/auth_entity.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/telegram_login_page.dart';
import 'features/home/presentation/pages/main_home_screen.dart';
import 'features/organizations/presentation/bloc/public_organization_invite_bloc.dart';
import 'features/organizations/presentation/pages/public_organization_invite_page.dart';

class MyApp extends StatefulWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final ExternalUrlLauncher _externalUrlLauncher;
  StreamSubscription<Uri>? _inviteDeepLinkSubscription;
  String? _pendingInviteToken;
  bool _showInviteLogin = false;
  bool _messagingInitializedForSession = false;

  @override
  void initState() {
    super.initState();
    _externalUrlLauncher = sl<ExternalUrlLauncher>();
    _inviteDeepLinkSubscription = _externalUrlLauncher.inviteDeepLinks.listen(
      _handleInviteDeepLink,
    );
    unawaited(_readInitialInviteDeepLink());
  }

  @override
  void dispose() {
    unawaited(_inviteDeepLinkSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      bloc: sl<ThemeCubit>(),
      builder: (context, mode) {
        return BlocProvider.value(
          value: widget.authBloc,
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
            current is Authenticated || current is AuthSuccess || current is Unauthenticated,
            listener: (context, state) {
              _syncMessagingForAuthState(state);

              if (state is Unauthenticated) {
                _navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const TelegramLoginPage()),
                      (route) => false,
                );
              }
            },
            child: ImmersiveModeGuard(
              child: MaterialApp(
                navigatorKey: _navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'مسار',
                locale: const Locale('ar', 'SY'),
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                themeMode: mode,
                home: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthError) {
                      debugPrint("Current auth error: ${state.message}");
                    } else {
                      debugPrint("Current auth state: ${state.runtimeType}");
                    }
                    _syncMessagingForAuthState(state);

                    final inviteToken = _pendingInviteToken;
                    if (inviteToken != null) {
                      return _buildInviteEntryPoint(state, inviteToken);
                    }

                    if (state is AuthInitial || state is AuthLoading) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    } else if (state is Authenticated) {
                      return MainHomeScreen(userAuthData: state.authEntity);
                    } else if (state is AuthSuccess) {
                      return MainHomeScreen(userAuthData: state.authEntity);
                    } else {
                      return const TelegramLoginPage();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _readInitialInviteDeepLink() async {
    try {
      final uri = await _externalUrlLauncher.takeInitialInviteDeepLink();
      if (uri != null && mounted) {
        _handleInviteDeepLink(uri);
      }
    } catch (_) {}
  }

  void _handleInviteDeepLink(Uri uri) {
    final token = ExternalUrlLauncher.inviteTokenFromUri(uri);
    if (token == null) return;

    unawaited(_clearInitialInviteDeepLink());
    if (!mounted) return;

    setState(() {
      _pendingInviteToken = token;
      _showInviteLogin = false;
    });
  }

  Future<void> _clearInitialInviteDeepLink() async {
    try {
      await _externalUrlLauncher.clearInitialInviteDeepLink();
    } catch (_) {}
  }

  void _clearPendingInvite() {
    unawaited(_clearInitialInviteDeepLink());
    if (!mounted) return;

    setState(() {
      _pendingInviteToken = null;
      _showInviteLogin = false;
    });
  }

  Widget _buildInviteEntryPoint(AuthState state, String token) {
    if (state is AuthInitial || state is AuthLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authEntity = _authEntityFromState(state);
    if (authEntity != null) {
      return BlocProvider(
        key: ValueKey('public-invite-$token'),
        create: (_) => sl<PublicOrganizationInviteBloc>(),
        child: PublicOrganizationInvitePage(
          token: token,
          isAuthenticated: true,
          onDismiss: _clearPendingInvite,
          onSignInRequested: () {},
          onAccepted: _clearPendingInvite,
        ),
      );
    }

    if (_showInviteLogin) {
      return const TelegramLoginPage();
    }

    return BlocProvider(
      key: ValueKey('public-invite-gate-$token'),
      create: (_) => sl<PublicOrganizationInviteBloc>(),
      child: PublicOrganizationInvitePage(
        token: token,
        isAuthenticated: false,
        onDismiss: _clearPendingInvite,
        onSignInRequested: () {
          setState(() => _showInviteLogin = true);
        },
        onAccepted: _clearPendingInvite,
      ),
    );
  }

  AuthEntity? _authEntityFromState(AuthState state) {
    if (state is Authenticated) return state.authEntity;
    if (state is AuthSuccess) return state.authEntity;
    return null;
  }

  void _syncMessagingForAuthState(AuthState state) {
    final authenticated = _authEntityFromState(state) != null;
    if (!authenticated) {
      _messagingInitializedForSession = false;
      return;
    }

    if (_messagingInitializedForSession) return;
    _messagingInitializedForSession = true;
    unawaited(sl<FirebaseMessagingService>().initialize());
  }
}
