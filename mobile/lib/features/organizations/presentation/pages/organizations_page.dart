import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/external_url_launcher.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/organization_bloc.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/organization_event.dart';
import '../bloc/organization_state.dart';
import '../bloc/public_organization_invite_bloc.dart';
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

class _InviteLinkEntryCard extends StatefulWidget {
  const _InviteLinkEntryCard();

  @override
  State<_InviteLinkEntryCard> createState() => _InviteLinkEntryCardState();
}

class _InviteLinkEntryCardState extends State<_InviteLinkEntryCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  String? _normalizedUrl;
  bool _hasInput = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInputChanged(String value) {
    setState(() {
      _hasInput = value.trim().isNotEmpty;
      _errorText = null;
      _normalizedUrl = null;
    });
  }

  void _openInvite() {
    final token = ExternalUrlLauncher.inviteTokenFromInput(_controller.text);
    if (token == null) {
      setState(() {
        _errorText = 'أدخل رابط دعوة صالح أو رمز الدعوة';
        _normalizedUrl = null;
      });
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
      _normalizedUrl = normalizedUrl;
    });

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
            _normalizedUrl = null;
          });
          context.read<OrganizationBloc>().add(GetAllOrganizationsEvent());
        });
  }

  void _clearInput() {
    _controller.clear();
    setState(() {
      _hasInput = false;
      _errorText = null;
      _normalizedUrl = null;
    });
    _focusNode.requestFocus();
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
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                label: const Text(
                  'فتح الدعوة داخل التطبيق',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
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
