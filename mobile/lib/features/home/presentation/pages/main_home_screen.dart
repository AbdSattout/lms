import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import '../../../../core/services/firebase_messaging_service.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../courses/presentation/bloc/course_details_bloc.dart';
import '../../../courses/presentation/bloc/course_details_event.dart';
import '../../../courses/presentation/bloc/my_courses_bloc.dart';
import '../../../courses/presentation/bloc/my_courses_event.dart';
import '../../../courses/presentation/pages/course_details_page.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../../organizations/presentation/bloc/organization_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/bloc/organization_event.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../../../organizations/presentation/pages/organizations_page.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/pages/profile_page.dart';

import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../../bloc/navbar_cubit.dart';

class MainHomeScreen extends StatelessWidget {
  final AuthEntity userAuthData;

  const MainHomeScreen({
    super.key,
    required this.userAuthData,
  });

  @override
  Widget build(BuildContext context) {
    final user = userAuthData.user;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NavbarCubit(),
        ),
        BlocProvider(
          create: (_) =>
          sl<NotificationsBloc>()..add(LoadNotificationsEvent()),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: _NotificationRefreshListener(
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
                      create: (_) =>
                      sl<HomeBloc>()..add(GetHomeDataEvent()),
                      child: _HomeContent(user: user),
                    ),
                    BlocProvider(
                      create: (_) =>
                      sl<MyCoursesBloc>()..add(GetMyEnrollmentsEvent()),
                      child: const MyCoursesPage(),
                    ),
                    BlocProvider(
                      create: (_) =>
                      sl<OrganizationBloc>()
                        ..add(GetAllOrganizationsEvent()),
                      child: OrganizationsPage(
                        currentUserName: user.name,
                      ),
                    ),
                    BlocProvider(
                      create: (_) =>
                      sl<ProfileBloc>()..add(GetProfileEvent()),
                      child: const ProfilePage(),
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: _buildSnakeBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildSnakeBar() {
    return BlocBuilder<NavbarCubit, int>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: 15,
          ),
          child: SnakeNavigationBar.color(
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.indicator,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            backgroundColor:
            Theme.of(context).scaffoldBackgroundColor,
            snakeViewColor:
            AppColors.primary.withValues(alpha: 0.10),
            height: 70,
            elevation: 10,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.72),
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
              _buildNavItem(
                'assets/navbar_icons/home.png',
                'الرئيسية',
              ),
              _buildNavItem(
                'assets/navbar_icons/book.png',
                'كورساتي',
              ),
              _buildNavItem(
                'assets/navbar_icons/categories.png',
                'المنظمات',
              ),
              _buildNavItem(
                'assets/navbar_icons/user.png',
                'حسابي',
              ),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(
      String iconPath,
      String label,
      ) {
    return BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage(iconPath),
        size: 22,
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ImageIcon(
          AssetImage(iconPath),
          size: 22,
        ),
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

    return ResilientNetworkAvatar(
      onTap: onTap,
      radius: radius,
      imageUrl: user.picture?.toString(),
      fallbackLabel: user.name?.toString(),
      backgroundColor: colors.surfaceContainerHighest,
      border: Border.all(
        color: Theme.of(context).dividerColor,
        width: isHome ? 2 : 4,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final dynamic user;

  const _HomeContent({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _WelcomeHeader(user: user),
          ),

          SliverToBoxAdapter(
            child: const SizedBox(height: 20),
          ),

          SliverToBoxAdapter(
            child: _SearchBar(),
          ),

          SliverToBoxAdapter(
            child: const SizedBox(height: 30),
          ),

          BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (state is HomeLoaded) {
                return SliverToBoxAdapter(
                  child: _HomeLoadedContent(
                    state: state,
                    user: user,
                  ),
                );
              }

              return const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 110),
          ),
        ],
      ),
    );
  }
}


class _WelcomeHeader extends StatelessWidget {
  final dynamic user;

  const _WelcomeHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final navbarCubit = context.read<NavbarCubit>();

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 52, 22, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            isDark
                ? AppColors.primary.withValues(alpha: 0.20)
                : AppColors.primaryLight,
            isDark
                ? AppColors.primary.withValues(alpha: 0.08)
                : colors.surface,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              MainHomeScreen.buildAvatar(
                user,
                context: context,
                radius: 25,
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
              const SizedBox(width: 14),

              Text(
                'مسار',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  fontSize: 38,
                ),
              ),

              const Spacer(),
              const _NotificationBellButton(),
            ],
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جاهز لتتعلم شيئاً جديداً؟',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اكتشف الكورسات والمنظمات المناسبة لك.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant.withValues(
                    alpha: isDark ? 0.35 : 0.55,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.16 : 0.05,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: TextField(
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ابحث عن كورس أو منظمة...',
                  hintStyle: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13.5,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                ),
                style: TextStyle(
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.24,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoadedContent extends StatelessWidget {
  final HomeLoaded state;
  final dynamic user;

  const _HomeLoadedContent({
    required this.state,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFeaturedCourse(context),

        const SizedBox(height: 32),

        _SectionHeader(
          title: 'المنظمات',
          subtitle: 'اكتشف مجتمعات تعليمية جديدة',
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

        const SizedBox(height: 14),

        _buildOrganizations(context),

        const SizedBox(height: 34),

        _SectionHeader(
          title: 'استكشف الكورسات',
          subtitle: 'اختر مهارتك القادمة',
          onViewAll: null,
        ),

        const SizedBox(height: 14),

        _buildCourses(context),
      ],
    );
  }

  Widget _buildFeaturedCourse(BuildContext context) {
    if (state.coursesError != null) {
      return _RetryCard(
        message: state.coursesError!,
        onRetry: () {
          context.read<HomeBloc>().add(
            GetHomeDataEvent(),
          );
        },
      );
    }

    final courses = state.courses ?? [];

    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }

    final course = courses.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: _FeaturedCourseCard(
        course: course,
        onTap: () => _openCourse(context, course),
      ),
    );
  }

  Widget _buildOrganizations(BuildContext context) {
    if (state.organizationsError != null) {
      return _RetryCard(
        message: state.organizationsError!,
        onRetry: () {
          context.read<HomeBloc>().add(
            GetHomeDataEvent(),
          );
        },
      );
    }

    final organizations = state.organizations ?? [];

    if (organizations.isEmpty) {
      return _EmptyState(
        icon: Icons.apartment_rounded,
        message: 'لا توجد منظمات حالياً',
      );
    }

    final preview = organizations.take(5).toList();

    return SizedBox(
      height: 185,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: preview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final organization = preview[index];

          return _HomeOrganizationCard(
            organization: organization,
            onTap: () => _openOrganization(
              context,
              organization,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourses(BuildContext context) {
    if (state.coursesError != null) {
      return const SizedBox.shrink();
    }

    final courses = state.courses ?? [];

    if (courses.isEmpty) {
      return _EmptyState(
        icon: Icons.menu_book_rounded,
        message: 'لا توجد كورسات منشورة حالياً',
      );
    }

    return SizedBox(
      height: 265,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final course = courses[index];

          return _HomeCourseCard(
            course: course,
            onTap: () => _openCourse(context, course),
          );
        },
      ),
    );
  }

  void _openOrganization(
      BuildContext context,
      OrganizationEntity organization,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
          sl<OrganizationDetailsBloc>()
            ..add(
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
  }

  Future<void> _openCourse(
      BuildContext context,
      CourseEntity course,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
          sl<CourseDetailsBloc>()
            ..add(
              GetCourseDetailsEvent(
                orgSlug:
                course.organization?.slug ?? '',
                courseSlug: course.slug,
              ),
            ),
          child: const CourseDetailsPage(),
        ),
      ),
    );

    if (context.mounted) {
      context.read<HomeBloc>().add(
        GetHomeDataEvent(),
      );
    }
  }
}



class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: colors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class _FeaturedCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const _FeaturedCourseCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasCover =
        course.coverUrl != null &&
            course.coverUrl!.isNotEmpty;

    final isEnrolled = course.enrollment != null;
    final isCompleted = course.isCompleted;
    final progress =
        course.enrollment?.progressPercentage ?? 0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 225,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover)
                Image.network(
                  course.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _fallbackBackground(),
                )
              else
                _fallbackBackground(),

              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.28, 1],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius:
                            BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                            ),
                          ),
                          child: Text(
                            isEnrolled
                                ? 'متابعة التعلم'
                                : 'ابدأ الآن',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    if (course.organizationName != null)
                      Text(
                        course.organizationName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.78,
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 5),

                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        if (isEnrolled)
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child:
                                  LinearProgressIndicator(
                                    value: (progress / 100)
                                        .clamp(0, 1),
                                    minHeight: 5,
                                    backgroundColor:
                                    Colors.white.withValues(
                                      alpha: 0.22,
                                    ),
                                    valueColor:
                                    const AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  isCompleted
                                      ? 'مكتملة بالكامل'
                                      : '${progress.toStringAsFixed(0)}٪ مكتمل',
                                  style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.8),
                                    fontSize: 10.5,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Spacer(),

                        const SizedBox(width: 12),

                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.55),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white24,
          size: 80,
        ),
      ),
    );
  }
}


class _HomeOrganizationCard extends StatelessWidget {
  final OrganizationEntity organization;
  final VoidCallback onTap;

  const _HomeOrganizationCard({
    required this.organization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final isPrivate =
        organization.visibility ==
            OrganizationVisibility.private;

    final hasImage =
        organization.image != null &&
            organization.image!.isNotEmpty;

    final visibilityColor = isPrivate
        ? (isDark
        ? const Color(0xffFBBF24)
        : const Color(0xffB4780F))
        : (isDark
        ? const Color(0xff86EFAC)
        : const Color(0xff2E7D53));

    return SizedBox(
      width: 220,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: isDark ? 0.35 : 0.55,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.14 : 0.04,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(16),
                        gradient: hasImage
                            ? null
                            : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary
                                .withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? Image.network(
                        organization.image!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                            _initials(),
                      )
                          : _initials(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                Text(
                  organization.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      isPrivate
                          ? Icons.lock_outline_rounded
                          : Icons.public_rounded,
                      size: 13,
                      color: visibilityColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPrivate ? 'خاصة' : 'عامة',
                      style: TextStyle(
                        color: visibilityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (organization.membersCount > 0) ...[
                      Icon(
                        Icons.people_alt_outlined,
                        size: 13,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${organization.membersCount}',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),

                if (organization.description != null &&
                    organization.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    organization.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _initials() {
    final name = organization.name.trim();
    final initial =
    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HomeCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const _HomeCourseCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasCover =
        course.coverUrl != null &&
            course.coverUrl!.isNotEmpty;

    final isEnrolled = course.enrollment != null;
    final isCompleted = course.isCompleted;
    final progress =
        course.enrollment?.progressPercentage ?? 0;

    return SizedBox(
      width: 235,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.045,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasCover)
                        Image.network(
                          course.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                              _placeholder(),
                        )
                      else
                        _placeholder(),

                      if (isCompleted)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                              const Color(0xff2E7D53),
                              borderRadius:
                              BorderRadius.circular(9),
                            ),
                            child: const Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'مكتملة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),

                        if (course.organizationName != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            course.organizationName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const Spacer(),

                        if (isEnrolled) ...[
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(8),
                            child:
                            LinearProgressIndicator(
                              value: (progress / 100)
                                  .clamp(0, 1),
                              minHeight: 5,
                              backgroundColor:
                              colors.surfaceContainerHighest,
                              valueColor:
                              AlwaysStoppedAnimation(
                                isCompleted
                                    ? const Color(0xff2E7D53)
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isCompleted
                                ? 'مكتملة بالكامل'
                                : '${progress.toStringAsFixed(0)}٪ مكتمل',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isCompleted
                                  ? const Color(0xff2E7D53)
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ] else
                          Row(
                            children: [
                              Text(
                                'استكشف الكورس',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 10.5,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_back_rounded,
                                size: 14,
                                color: colors.primary,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.60),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 26,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest
              .withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetryCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RetryCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest
              .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRefreshListener
    extends StatefulWidget {
  final Widget child;

  const _NotificationRefreshListener({
    required this.child,
  });

  @override
  State<_NotificationRefreshListener> createState() =>
      _NotificationRefreshListenerState();
}

class _NotificationRefreshListenerState
    extends State<_NotificationRefreshListener> {
  StreamSubscription? _subscription;
  Timer? _delayedRefresh;
  late NotificationsBloc _notificationsBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _notificationsBloc = context.read();

    _subscription ??= sl<FirebaseMessagingService>()
        .messages
        .listen((_) {
      _refreshNotifications();

      _delayedRefresh?.cancel();
      _delayedRefresh = Timer(
        const Duration(milliseconds: 1200),
        _refreshNotifications,
      );
    });
  }

  @override
  void dispose() {
    _delayedRefresh?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _refreshNotifications() {
    if (!mounted) return;

    _notificationsBloc.add(
      RefreshNotificationsEvent(),
    );
  }
}

class _NotificationBellButton
    extends StatelessWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc,
        NotificationsState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        final unreadCount =
        state is NotificationsLoaded
            ? state.unreadCount
            : 0;

        final inviteCount =
        state is NotificationsLoaded
            ? state.invites.length
            : 0;

        final badgeCount =
        unreadCount > inviteCount
            ? unreadCount
            : inviteCount;

        final hasBadge = badgeCount > 0;

        final activeColor =
        isDark
            ? AppColors.primaryLight
            : colors.primary;

        final backgroundColor = hasBadge
            ? activeColor.withValues(
          alpha: isDark ? 0.16 : 0.10,
        )
            : colors.surface.withValues(
          alpha: isDark ? 0.72 : 0.88,
        );

        final borderColor = hasBadge
            ? activeColor.withValues(
          alpha: isDark ? 0.30 : 0.22,
        )
            : colors.outlineVariant.withValues(
          alpha: isDark ? 0.28 : 0.45,
        );

        final iconColor =
        hasBadge
            ? activeColor
            : colors.onSurfaceVariant;

        return Tooltip(
          message: 'الإشعارات',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context
                          .read<NotificationsBloc>(),
                      child:
                      const NotificationsPage(),
                    ),
                  ),
                );

                if (context.mounted) {
                  context
                      .read<NotificationsBloc>()
                      .add(
                    RefreshNotificationsEvent(),
                  );
                }
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius:
                  BorderRadius.circular(15),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        hasBadge
                            ? Icons
                            .notifications_active_rounded
                            : Icons.notifications_rounded,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: 3,
                        left: 3,
                        child: _NotificationBadge(
                          count: badgeCount,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    final colors = Theme.of(context).colorScheme;
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 20,
      constraints:
      const BoxConstraints(minWidth: 20),
      padding:
      const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius:
        BorderRadius.circular(999),
        border: Border.all(
          color: colors.surface,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.36 : 0.14,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}