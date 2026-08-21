import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../domain/entities/friend_user_entity.dart';
import '../../domain/entities/search_user_entity.dart';
import '../bloc/add_friend_bloc.dart';
import '../bloc/add_friend_event.dart';
import '../bloc/add_friend_state.dart';
import '../bloc/user_profile_bloc.dart';
import '../bloc/user_profile_event.dart' show LoadUserProfileEvent;
import 'user_profile_page.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  late final AddFriendBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<AddFriendBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('إضافة صديق'),
            centerTitle: true,
          ),
          body: BlocConsumer<AddFriendBloc, AddFriendState>(
            listenWhen: (previous, current) {
              if (current is! AddFriendLoaded) return false;
              if (current.actionMessage != null) return true;
              if (current.errorMessage != null) return true;
              return false;
            },
            listener: (context, state) {
              if (state is! AddFriendLoaded) return;

              final message = state.actionMessage ?? state.errorMessage;
              if (message == null) return;

              AppToast.error(context, message: message);

            },
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                    child: ListenableBuilder(
                      listenable: _searchController,
                      builder: (context, _) => TextField(
                        controller: _searchController,
                        onChanged: _onQueryChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'ابحث بالاسم أو اسم المستخدم',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    _bloc.add(ClearAddFriendEvent());
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AddFriendState state) {
    if (state is AddFriendInitial) {
      return const _HintView(
        icon: Icons.person_search_rounded,
        message: 'ابحث عن مستخدم لإرسال طلب صداقة',
      );
    }

    if (state is AddFriendLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AddFriendError) {
      return _ErrorView(
        message: state.message,
        onRetry: () {
          _bloc.add(SearchUsersEvent(_searchController.text));
        },
      );
    }

    if (state is AddFriendLoaded) {
      final results = state.results;
      if (results.isEmpty) {
        return const _HintView(
          icon: Icons.search_off_rounded,
          message: 'لا توجد نتائج مطابقة',
        );
      }

      return ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final user = results[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SearchResultTile(
              user: user,
              isProcessing: state.processingUserId == user.id,
              isRequestSent: state.sentRequestIds.contains(user.id),
              onAdd: () {
                _bloc.add(SendFriendRequestEvent(user.id));
              },
              onTap: () => _openProfile(context, user),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _bloc.add(SearchUsersEvent(value));
    });
  }

  Future<void> _openProfile(BuildContext context, SearchUserEntity user) async {
    final initialUser = FriendUserEntity(
      id: user.id,
      name: user.name,
      username: user.username,
      picture: user.picture,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<UserProfileBloc>()..add(LoadUserProfileEvent(user.id)),
          child: UserProfilePage(userId: user.id, initialUser: initialUser),
        ),
      ),
    );

    if (!mounted) return;
    _bloc.add(SearchUsersEvent(_searchController.text));
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchUserEntity user;
  final bool isProcessing;
  final bool isRequestSent;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.user,
    required this.isProcessing,
    required this.isRequestSent,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtitle = user.username?.trim().isNotEmpty == true
        ? '@${user.username}'
        : user.email;

    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ResilientNetworkAvatar(
                radius: 24,
                imageUrl: user.picture,
                fallbackLabel: user.name,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (isProcessing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isRequestSent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'بانتظار القبول',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              else
                IconButton.filled(
                  onPressed: onAdd,
                  tooltip: 'إضافة كصديق',
                  icon: const Icon(Icons.person_add_alt_rounded, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _HintView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 50,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
