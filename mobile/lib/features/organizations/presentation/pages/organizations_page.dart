import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/external_url_launcher.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/organization_invite_entity.dart';
import '../bloc/organization_bloc.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/organization_event.dart';
import '../bloc/organization_state.dart';
import '../bloc/public_organization_invite_bloc.dart';
import '../bloc/public_organization_invite_event.dart';
import '../bloc/public_organization_invite_state.dart';
import '../widgets/organization_card.dart';
import 'organization_details_page.dart';
import 'public_organization_invite_page.dart';

class OrganizationsPage extends StatelessWidget {
  final String? currentUserName;

  const OrganizationsPage({super.key, this.currentUserName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OrganizationBloc, OrganizationState>(
          listenWhen: (previous, current) => current is OrganizationError,
          listener: (context, state) {
            if (state is OrganizationError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is OrganizationLoading || state is OrganizationInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrganizationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: colors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OrganizationBloc>().add(
                            GetAllOrganizationsEvent(),
                          );
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is OrganizationLoaded) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 28,
                      left: 22,
                      right: 22,
                      bottom: 24,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                    ),
                    child: Text(
                      'المنظمات',
                      style: textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<OrganizationBloc>().add(
                          GetAllOrganizationsEvent(),
                        );
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 18, bottom: 100),
                        children: [
                          const _InviteLinkEntryCard(),
                          if (state.organizations.isEmpty) ...[
                            const SizedBox(height: 34),
                            _EmptyOrganizationsState(
                              color: colors.primary,
                              textStyle: textTheme.bodyLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ] else
                            ...state.organizations.map((organization) {
                              final isOwnedByMe =
                                  currentUserName != null &&
                                  organization.ownerName != null &&
                                  organization.ownerName == currentUserName;

                              return OrganizationCard(
                                organization: organization,
                                isOwnedByMe: isOwnedByMe,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (_) =>
                                            sl<OrganizationDetailsBloc>()..add(
                                              GetOrganizationDetailsEvent(
                                                organization.slug,
                                              ),
                                            ),
                                        child: OrganizationDetailsPage(
                                          slug: organization.slug,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _InviteLinkEntryCard extends StatelessWidget {
  const _InviteLinkEntryCard();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PublicOrganizationInviteBloc>(),
      child: const _InviteLinkEntryCardBody(),
    );
  }
}

class _InviteLinkEntryCardBody extends StatefulWidget {
  const _InviteLinkEntryCardBody();

  @override
  State<_InviteLinkEntryCardBody> createState() =>
      _InviteLinkEntryCardBodyState();
}

class _InviteLinkEntryCardBodyState extends State<_InviteLinkEntryCardBody> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _previewDebounce;
  String? _errorText;
  String? _normalizedUrl;
  String? _currentToken;
  bool _hasInput = false;

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInputChanged(String value) {
    _previewDebounce?.cancel();
    final token = ExternalUrlLauncher.inviteTokenFromInput(value);

    setState(() {
      _hasInput = value.trim().isNotEmpty;
      _errorText = null;
      _currentToken = token;
      _normalizedUrl = token == null
          ? null
          : ExternalUrlLauncher.publicInviteUrlForToken(token);
    });

    if (token == null) {
      context.read<PublicOrganizationInviteBloc>().add(
        ResetPublicOrganizationInviteEvent(),
      );
      return;
    }

    _previewDebounce = Timer(const Duration(milliseconds: 550), () {
      if (!mounted || !_shouldPreviewToken(token)) return;
      context.read<PublicOrganizationInviteBloc>().add(
        PreviewPublicOrganizationInviteEvent(token),
      );
    });
  }

  void _openInvite() {
    final token = ExternalUrlLauncher.inviteTokenFromInput(_controller.text);
    if (token == null) {
      setState(() {
        _errorText = 'أدخل رابط دعوة صالح أو رمز الدعوة';
        _normalizedUrl = null;
        _currentToken = null;
      });
      context.read<PublicOrganizationInviteBloc>().add(
        ResetPublicOrganizationInviteEvent(),
      );
      return;
    }

    final normalizedUrl = ExternalUrlLauncher.publicInviteUrlForToken(token);
    _controller.value = TextEditingValue(
      text: normalizedUrl,
      selection: TextSelection.collapsed(offset: normalizedUrl.length),
    );
    _focusNode.unfocus();
    setState(() {
      _hasInput = true;
      _errorText = null;
      _currentToken = token;
      _normalizedUrl = normalizedUrl;
    });

    final inviteState = context.read<PublicOrganizationInviteBloc>().state;
    final hasCurrentPreview =
        inviteState.token == token && inviteState.invite != null;

    if (inviteState.isPreviewing && inviteState.token == token) return;

    if (!hasCurrentPreview) {
      context.read<PublicOrganizationInviteBloc>().add(
        PreviewPublicOrganizationInviteEvent(token),
      );
      return;
    }

    if (inviteState.invite!.alreadyJoined) return;

    _openAcceptPage(token);
  }

  void _openAcceptPage(String token) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(
            builder: (routeContext) => BlocProvider(
              create: (_) => sl<PublicOrganizationInviteBloc>(),
              child: PublicOrganizationInvitePage(
                token: token,
                isAuthenticated: true,
                onDismiss: () => Navigator.of(routeContext).pop(false),
                onSignInRequested: () {},
                onAccepted: () => Navigator.of(routeContext).pop(true),
              ),
            ),
          ),
        )
        .then((accepted) {
          if (!mounted || accepted != true) return;

          _controller.clear();
          setState(() {
            _hasInput = false;
            _currentToken = null;
            _normalizedUrl = null;
          });
          context.read<PublicOrganizationInviteBloc>().add(
            ResetPublicOrganizationInviteEvent(),
          );
          context.read<OrganizationBloc>().add(GetAllOrganizationsEvent());
        });
  }

  void _clearInput() {
    _previewDebounce?.cancel();
    _controller.clear();
    setState(() {
      _hasInput = false;
      _errorText = null;
      _normalizedUrl = null;
      _currentToken = null;
    });
    context.read<PublicOrganizationInviteBloc>().add(
      ResetPublicOrganizationInviteEvent(),
    );
    _focusNode.requestFocus();
  }

  bool _shouldPreviewToken(String token) {
    final input = _controller.text.trim().toLowerCase();
    return token.length >= 8 ||
        input.contains('/invite/') ||
        input.startsWith('lms://invite');
  }

  void _openOrganizationDetails(OrganizationInviteOrganizationEntity org) {
    if (org.slug.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<OrganizationDetailsBloc>()
                ..add(GetOrganizationDetailsEvent(org.slug)),
          child: OrganizationDetailsPage(slug: org.slug),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.add_link_rounded,
                    color: colors.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فتح دعوة برابط',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ألصق الرابط الكامل أو رمز الدعوة فقط',
                        style: textTheme.bodySmall?.copyWith(
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _handleInputChanged,
              onSubmitted: (_) => _openInvite(),
              decoration: InputDecoration(
                hintText: 'https://lmscenter.vercel.app/invite/...',
                errorText: _errorText,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: Icon(Icons.link_rounded, color: colors.primary),
                suffixIcon: _hasInput
                    ? IconButton(
                        onPressed: _clearInput,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'مسح',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.primary, width: 1.4),
                ),
              ),
            ),
            BlocBuilder<
              PublicOrganizationInviteBloc,
              PublicOrganizationInviteState
            >(
              builder: (context, inviteState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_normalizedUrl != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.auto_fix_high_rounded,
                            size: 17,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              _normalizedUrl!,
                              textDirection: TextDirection.ltr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    _InvitePreviewArea(
                      state: inviteState,
                      currentToken: _currentToken,
                      onViewOrganization: _openOrganizationDetails,
                    ),
                    const SizedBox(height: 14),
                    _InviteEntryButton(
                      state: inviteState,
                      currentToken: _currentToken,
                      onPressed: _openInvite,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitePreviewArea extends StatelessWidget {
  final PublicOrganizationInviteState state;
  final String? currentToken;
  final ValueChanged<OrganizationInviteOrganizationEntity> onViewOrganization;

  const _InvitePreviewArea({
    required this.state,
    required this.currentToken,
    required this.onViewOrganization,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentToken = currentToken != null && state.token == currentToken;
    if (!isCurrentToken) return const SizedBox.shrink();

    if (state.isPreviewing) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: _InviteStatusStrip(
          icon: Icons.search_rounded,
          message: 'جاري التحقق من الدعوة...',
          isLoading: true,
        ),
      );
    }

    if (state.hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _InviteStatusStrip(
          icon: Icons.error_outline_rounded,
          message: state.message ?? 'تعذر التحقق من الدعوة',
          color: Colors.red,
        ),
      );
    }

    final invite = state.invite;
    if (invite == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _InvitePreviewPanel(
        invite: invite,
        onViewOrganization: () => onViewOrganization(invite.organization),
      ),
    );
  }
}

class _InviteEntryButton extends StatelessWidget {
  final PublicOrganizationInviteState state;
  final String? currentToken;
  final VoidCallback onPressed;

  const _InviteEntryButton({
    required this.state,
    required this.currentToken,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentToken = currentToken != null && state.token == currentToken;
    final isChecking = isCurrentToken && state.isPreviewing;
    final alreadyJoined =
        isCurrentToken && state.invite != null && state.invite!.alreadyJoined;
    final hasPreview = isCurrentToken && state.invite != null;
    final text = alreadyJoined
        ? 'أنت منضم بالفعل'
        : hasPreview
        ? 'متابعة قبول الدعوة'
        : 'فحص الدعوة';

    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isChecking || alreadyJoined ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadyJoined
              ? const Color(0xff238A5A)
              : AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: alreadyJoined
              ? const Color(0xff238A5A).withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.44),
          disabledForegroundColor: alreadyJoined
              ? const Color(0xff238A5A)
              : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isChecking
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Icon(
                alreadyJoined
                    ? Icons.check_circle_rounded
                    : Icons.open_in_new_rounded,
                size: 20,
              ),
        label: Text(
          isChecking ? 'جاري التحقق...' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _InvitePreviewPanel extends StatelessWidget {
  final OrganizationInviteEntity invite;
  final VoidCallback onViewOrganization;

  const _InvitePreviewPanel({
    required this.invite,
    required this.onViewOrganization,
  });

  @override
  Widget build(BuildContext context) {
    final org = invite.organization;
    final overview = invite.overview;
    final colors = Theme.of(context).colorScheme;
    final alreadyJoined = invite.alreadyJoined;
    final statusColor = alreadyJoined
        ? const Color(0xff238A5A)
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InviteOrganizationLogo(organization: org),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            org.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _InviteStatusBadge(
                          color: statusColor,
                          label: alreadyJoined ? 'منضم' : 'جاهزة',
                          icon: alreadyJoined
                              ? Icons.check_circle_rounded
                              : Icons.verified_rounded,
                        ),
                      ],
                    ),
                    if (org.ownerName != null && org.ownerName!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        org.ownerName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (org.description != null &&
                        org.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        org.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _InviteMetricChip(
                icon: Icons.group_rounded,
                label: '${overview?.membersCount ?? 0} عضو',
              ),
              _InviteMetricChip(
                icon: Icons.school_rounded,
                label: '${overview?.publishedCoursesCount ?? 0} كورس',
              ),
              _InviteMetricChip(
                icon: Icons.badge_rounded,
                label: _roleLabel(invite.role),
              ),
              if (invite.maxUses != null)
                _InviteMetricChip(
                  icon: Icons.how_to_reg_rounded,
                  label: '${invite.usedCount}/${invite.maxUses}',
                ),
            ],
          ),
          const SizedBox(height: 12),
          _InviteStatusStrip(
            icon: alreadyJoined
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            message: alreadyJoined
                ? 'أنت عضو في هذه المنظمة بالفعل، لا تحتاج لقبول الدعوة مرة أخرى.'
                : 'تم العثور على المنظمة. يمكنك متابعة قبول الدعوة داخل التطبيق.',
            color: statusColor,
          ),
          if (org.slug.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onViewOrganization,
                style: OutlinedButton.styleFrom(
                  foregroundColor: statusColor,
                  side: BorderSide(color: statusColor.withValues(alpha: 0.28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.apartment_rounded, size: 19),
                label: const Text(
                  'عرض المنظمة',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'مشرف';
      case 'OWNER':
        return 'مالك';
      default:
        return 'طالب';
    }
  }
}

class _InviteOrganizationLogo extends StatelessWidget {
  final OrganizationInviteOrganizationEntity organization;

  const _InviteOrganizationLogo({required this.organization});

  @override
  Widget build(BuildContext context) {
    final imageUrl = organization.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.primary.withValues(alpha: 0.14),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial(),
            )
          : _initial(),
    );
  }

  Widget _initial() {
    final name = organization.name.trim();
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InviteStatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _InviteStatusBadge({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InviteMetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteStatusStrip extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? color;
  final bool isLoading;

  const _InviteStatusStrip({
    required this.icon,
    required this.message,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: accent),
            )
          else
            Icon(icon, size: 19, color: accent),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: accent,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrganizationsState extends StatelessWidget {
  final Color color;
  final TextStyle? textStyle;

  const _EmptyOrganizationsState({required this.color, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.apartment_rounded, size: 40, color: color),
          ),
          const SizedBox(height: 16),
          Text('لا توجد منظمات حالياً', style: textStyle),
        ],
      ),
    );
  }
}
