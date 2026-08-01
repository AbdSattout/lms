import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/organization_bloc.dart';
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
    return Scaffold(

      body: SafeArea(
        child: BlocConsumer<OrganizationBloc, OrganizationState>(
          listenWhen: (previous, current) =>
          current is OrganizationError,
          listener: (context, state) {
            if (state is OrganizationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is OrganizationLoading ||
                state is OrganizationInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is OrganizationError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<OrganizationBloc>()
                              .add(GetAllOrganizationsEvent());
                        },
                        child: const Text(
                          'إعادة المحاولة',
                        ),
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
                      top: 24,
                      left: 22,
                      right: 22,
                      bottom: 22,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                    ),
                    child: const Text(
                      'المنظمات',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  Expanded(
                    child: state.organizations.isEmpty
                        ? const Center(
                      child: Text(
                        'لا توجد منظمات حالياً',
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

                          final isOwnedByMe =
                              currentUserName != null &&
                                  organization.ownerName !=
                                      null &&
                                  organization.ownerName ==
                                      currentUserName;

                          return OrganizationCard(
                            organization: organization,
                            isOwnedByMe: isOwnedByMe,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrganizationDetailsPage(
                                    slug: organization.slug,
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