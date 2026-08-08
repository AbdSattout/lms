import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import 'package:lms/features/profile/presentation/pages/profile_page.dart';

import '../../../courses/presentation/bloc/course_details_bloc.dart';
import '../../../courses/presentation/bloc/course_details_event.dart';
import '../../../courses/presentation/bloc/my_courses_bloc.dart';
import '../../../courses/presentation/bloc/my_courses_event.dart';
import '../../../courses/presentation/pages/course_details_page.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../../organizations/presentation/bloc/organization_bloc.dart';
import '../../../organizations/presentation/bloc/organization_event.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/pages/organizations_page.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../../../organizations/presentation/widgets/organization_card.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../../bloc/navbar_cubit.dart';

class MainHomeScreen extends StatelessWidget {
  final AuthEntity userAuthData;

  const MainHomeScreen({super.key, required this.userAuthData});

  @override
  Widget build(BuildContext context) {
    final user = userAuthData.user;

    return BlocProvider(
      create: (context) => NavbarCubit(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBody: true,
          body: BlocBuilder<NavbarCubit, int>(
            builder: (context, state) {
              return PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: context.read<NavbarCubit>().controller,
                children: [
                  BlocProvider(
                    create: (_) => sl<HomeBloc>()..add(GetHomeDataEvent()),
                    child: _HomeContent(user: user),
                  ),
                  BlocProvider(
                    create: (_) =>
                        sl<MyCoursesBloc>()..add(GetMyEnrollmentsEvent()),
                    child: const MyCoursesPage(),
                  ),
                  BlocProvider(
                    create: (_) =>
                        sl<OrganizationBloc>()..add(GetAllOrganizationsEvent()),
                    child: OrganizationsPage(currentUserName: user.name),
                  ),
                  BlocProvider(
                    create: (_) => sl<ProfileBloc>()..add(GetProfileEvent()),
                    child: const ProfilePage(),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: _buildSnakeBar(),
        ),
      ),
    );
  }

  Widget _buildSnakeBar() {
    return BlocBuilder<NavbarCubit, int>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 15),
          child: SnakeNavigationBar.color(
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.indicator,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            snakeViewColor: AppColors.primary.withValues(alpha: 0.10),
            height: 70,
            elevation: 10,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: state,
            onTap: (index) {
              context.read<NavbarCubit>().controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear,
              );
              context.read<NavbarCubit>().update(index);
            },
            items: [
              _buildNavItem('assets/navbar_icons/home.png', 'الرئيسية'),
              _buildNavItem('assets/navbar_icons/book.png', 'كورساتي'),
              _buildNavItem('assets/navbar_icons/categories.png', 'المنظمات'),
              _buildNavItem('assets/navbar_icons/user.png', 'حسابي'),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: ImageIcon(AssetImage(iconPath), size: 22),
      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ImageIcon(AssetImage(iconPath), size: 22),
      ),
      label: label,
    );
  }

  static Widget buildAvatar(
    dynamic user, {
    required BuildContext context,
    required double radius,
    bool isHome = false,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    bool hasValidImage =
        user.picture != null && user.picture.toString().startsWith('http');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: isHome ? 2 : 4,
          ),
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: colors.surfaceContainerHighest,
          backgroundImage: hasValidImage
              ? NetworkImage(user.picture)
              : const AssetImage('assets/images/user.png') as ImageProvider,
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final dynamic user;
  const _HomeContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(child: _searchBar(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (state is HomeLoaded) {
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _sectionHeader(
                        context,
                        title: 'المنظمات',
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) =>
                                    sl<OrganizationBloc>()
                                      ..add(GetAllOrganizationsEvent()),
                                child: OrganizationsPage(
                                  currentUserName: user.name,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      _organizationsSection(context, state),
                      const SizedBox(height: 12),
                      _sectionHeader(context, title: 'استكشف الكورسات'),
                      _coursesSection(context, state),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final navbarCubit = context.read<NavbarCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 24, left: 22, right: 22, bottom: 22),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.primaryLight,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            child: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
          ),
          Row(
            children: [
              Text(
                "مسار",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 42,
                ),
              ),
              const SizedBox(width: 14),
              MainHomeScreen.buildAvatar(
                user,
                context: context,
                radius: 23,
                isHome: true,
                onTap: () {
                  navbarCubit.controller.animateToPage(
                    3,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  navbarCubit.update(3);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ابحث عن كورس أو مسار...',
                  hintStyle: TextStyle(color: colors.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: TextStyle(color: colors.onSurface),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onViewAll,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                "عرض الكل",
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _organizationsSection(BuildContext context, HomeLoaded state) {
    if (state.organizationsError != null) {
      return _retryCard(
        context,
        state.organizationsError!,
        () => context.read<HomeBloc>().add(GetHomeDataEvent()),
      );
    }

    final organizations = state.organizations ?? [];
    if (organizations.isEmpty) {
      return _emptyCard('لا توجد منظمات حالياً');
    }

    final preview = organizations.take(5).toList();

    return Column(
      children: preview
          .map(
            (org) => OrganizationCard(
              organization: org,
              onTap: () {
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
              },
            ),
          )
          .toList(),
    );
  }

  Widget _coursesSection(BuildContext context, HomeLoaded state) {
    if (state.coursesError != null) {
      return _retryCard(
        context,
        state.coursesError!,
        () => context.read<HomeBloc>().add(GetHomeDataEvent()),
      );
    }

    final courses = state.courses ?? [];
    if (courses.isEmpty) {
      return _emptyCard('لا توجد كورسات منشورة حالياً');
    }

    return Column(
      children: courses.map((course) {
        return CourseCard(
          course: course,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<CourseDetailsBloc>()
                    ..add(
                      GetCourseDetailsEvent(
                        orgSlug: course.organization?.slug ?? '',
                        courseSlug: course.slug,
                      ),
                    ),
                  child: const CourseDetailsPage(),
                ),
              ),
            );

            if (context.mounted) {
              context.read<HomeBloc>().add(GetHomeDataEvent());
            }
          },
        );
      }).toList(),
    );
  }

  Widget _emptyCard(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Builder(
        builder: (context) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _retryCard(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
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
