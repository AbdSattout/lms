import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/organization_bloc.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/organization_event.dart';
import '../bloc/organization_state.dart';
import '../widgets/organization_card.dart';
import 'organization_details_page.dart';

class OrganizationsPage extends StatelessWidget {
  final String? currentUserName;
  const OrganizationsPage({
    super.key,
    this.currentUserName,
  });

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
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
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: colors.error),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<OrganizationBloc>()
                              .add(GetAllOrganizationsEvent());
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
                      color: colors.primary.withOpacity(0.08),
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
                    child: state.organizations.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.apartment_rounded,
                                size: 40, color: colors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد منظمات حالياً',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                        : RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<OrganizationBloc>()
                            .add(GetAllOrganizationsEvent());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 18,
                          bottom: 24,
                        ),
                        itemCount: state.organizations.length,
                        itemBuilder: (context, index) {
                          final organization =
                          state.organizations[index];
                          final isOwnedByMe = currentUserName != null &&
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
                                    sl<OrganizationDetailsBloc>()
                                      ..add(GetOrganizationDetailsEvent(
                                          organization.slug)),
                                    child: OrganizationDetailsPage(
                                        slug: organization.slug),
                                  ),
                                ),
                              );
                            },
                          );
                        },
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