import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

import '../../../../core/services/firebase_messaging_service.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/services/user_picture_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/pages/chats_page.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../courses/presentation/bloc/course_details_bloc.dart';
import '../../../courses/presentation/bloc/course_details_event.dart';
import '../../../courses/presentation/bloc/my_courses_bloc.dart';
import '../../../courses/presentation/bloc/my_courses_event.dart';
import '../../../courses/presentation/pages/all_courses_page.dart';
import '../../../courses/presentation/pages/course_details_page.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../../organizations/presentation/bloc/organization_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../../../organizations/presentation/pages/organizations_page.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../organizations/presentation/widgets/organization_card.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/pages/profile_page.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../bloc/navbar_cubit.dart';

class MainHomeScreen extends StatelessWidget {
  final AuthEntity userAuthData;

  const MainHomeScreen({super.key, required this.userAuthData});
  @override
  Widget build(BuildContext context) {
    final user = userAuthData.user;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavbarCubit()),
        BlocProvider(
          create: (_) => sl<NotificationsBloc>()..add(LoadNotificationsEvent()),
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
                      create: (_) => sl<HomeBloc>()..add(GetHomeDataEvent()),
                      child: _HomeContent(user: user),
                    ),
                    BlocProvider(
                      create: (_) =>
                          sl<MyCoursesBloc>()..add(GetMyEnrollmentsEvent()),
                      child: const MyCoursesPage(),
                    ),
                    BlocProvider(
                      create: (_) => sl<OrganizationBloc>(),
                      child: OrganizationsPage(
                        currentUserName: user.name,
                        showOnlyMine: true,
                      ),
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
      ),
    );
  }

  Widget _buildSnakeBar() {
    return BlocBuilder<NavbarCubit, int>(
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 15),
          child: SnakeNavigationBar.color(
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.indicator,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            backgroundColor: isDark
                ? const Color(0xff1E293B)  
                : AppColors.lavenderLight,
            snakeViewColor: Colors.transparent,
            height: 68,
            elevation: 20,
            selectedItemColor: colors.primary,
            unselectedItemColor: colors.onSurfaceVariant.withValues(alpha: 0.55),
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
              _buildNavItem('assets/navbar_icons/categories.png', 'منظماتي'),
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
        String? imageUrlOverride,
      }) {
    final colors = Theme.of(context).colorScheme;

    return ResilientNetworkAvatar(
      onTap: onTap,
      radius: radius,
      imageUrl: imageUrlOverride ?? user.picture?.toString(),
      fallbackLabel: user.name?.toString(),
      backgroundColor: colors.surfaceContainerHighest,
      border: Border.all(
        color: Theme.of(context).dividerColor,
        width: isHome ? 2 : 4,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final dynamic user;
  const _HomeContent({required this.user});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  dynamic get user => widget.user;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openOrganization(BuildContext context, OrganizationEntity organization) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<OrganizationDetailsBloc>()
            ..add(GetOrganizationDetailsEvent(organization.slug)),
          child: OrganizationDetailsPage(slug: organization.slug),
        ),
      ),
    );
  }

  Future<void> _openCourse(BuildContext context, CourseEntity course) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<CourseDetailsBloc>()
            ..add(GetCourseDetailsEvent(
              orgSlug: course.organization?.slug ?? '',
              courseSlug: course.slug,
            )),
          child: const CourseDetailsPage(),
        ),
      ),
    );
    if (context.mounted) {
      context.read<HomeBloc>().add(GetHomeDataEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final hasSearchQuery = state is HomeLoaded && state.searchQuery.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              if (hasSearchQuery) {
                context.read<HomeBloc>().add(SearchQueryChanged(state.searchQuery));
              } else {
                context.read<HomeBloc>().add(GetHomeDataEvent());
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _WelcomeHeader(user: user)),
                SliverToBoxAdapter(child: const SizedBox(height: 20)),
                SliverToBoxAdapter(
                  child: _SearchBar(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<HomeBloc>().add(SearchQueryChanged(query));
                    },
                    onClear: () {
                      _searchController.clear();
                      context.read<HomeBloc>().add(ClearSearch());
                    },
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 30)),
                if (hasSearchQuery)
                  _buildSearchResults(context, state)
                else
                  ..._buildNormalContent(context, state),
                SliverToBoxAdapter(child: const SizedBox(height: 110)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildNormalContent(BuildContext context, HomeState state) {
    return [
      BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (state is HomeLoaded) {
            return SliverToBoxAdapter(
              child: _HomeLoadedContent(state: state, user: user),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }

  Widget _buildSearchResults(BuildContext context, HomeState state) {
    if (state is! HomeLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'نتائج البحث',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'المنظمات', subtitle: 'نتائج المطابقة', onViewAll: null),
          const SizedBox(height: 12),
          if (state.isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.searchOrganizationsError != null)
            _RetryCard(message: state.searchOrganizationsError!, onRetry: () {})
          else if (state.searchOrganizations == null || state.searchOrganizations!.isEmpty)
              _EmptyState(icon: Icons.apartment_rounded, message: 'لا توجد منظمات مطابقة')
            else
              ...state.searchOrganizations!.map((org) => OrganizationCard(
                organization: org,
                onTap: () => _openOrganization(context, org),
              )),
          const SizedBox(height: 24),
          _SectionHeader(title: 'الكورسات', subtitle: 'نتائج المطابقة', onViewAll: null),
          const SizedBox(height: 12),
          if (state.isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.searchCoursesError != null)
            _RetryCard(message: state.searchCoursesError!, onRetry: () {})
          else if (state.searchCourses == null || state.searchCourses!.isEmpty)
              _EmptyState(icon: Icons.menu_book_rounded, message: 'لا توجد كورسات مطابقة')
            else
              ...state.searchCourses!.map((course) => CourseCard(
                course: course,
                onTap: () => _openCourse(context, course),
              )),
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
            isDark ? AppColors.primary.withValues(alpha: 0.08) : AppColors.lavenderLight,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: UserPictureNotifier.pictureUrl,
                builder: (context, picture, _) {
                  return MainHomeScreen.buildAvatar(
                    user,
                    context: context,
                    radius: 25,
                    isHome: true,
                    imageUrlOverride: picture,
                    onTap: () {
                      navbarCubit.controller.animateToPage(
                        3,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      navbarCubit.update(3);
                    },
                  );
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
              const _ChatButton(),
              const SizedBox(width: 14),
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
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'ابحث عن كورس أو منظمة...',
            hintStyle: TextStyle(color: colors.onSurfaceVariant, fontSize: 13.5),
            prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded, size: 18, color: colors.onSurfaceVariant),
                );
              },
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
          style: TextStyle(color: colors.onSurface),
        ),
      ),
    );
  }
}
class _HomeLoadedContent extends StatelessWidget {
  final HomeLoaded state;
  final dynamic user;

  const _HomeLoadedContent({required this.state, required this.user});

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
                  create: (_) => sl<OrganizationBloc>(),
                  child: OrganizationsPage(
                    currentUserName: user.name,
                    showOnlyMine: false,
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
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllCoursesPage()),
            );
          },
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
          context.read<HomeBloc>().add(GetHomeDataEvent());
        },
      );
    }

    final recommendations = state.recommendedCourses ?? [];

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final recommendation = recommendations.first;
    final course = recommendation.course;

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
          context.read<HomeBloc>().add(GetHomeDataEvent());
        },
      );
    }

    final recommendations = state.recommendedOrganizations ?? [];

    if (recommendations.isEmpty) {
      return _EmptyState(
        icon: Icons.apartment_rounded,
        message: 'لا توجد منظمات حالياً',
      );
    }

    final preview = recommendations.take(5).toList();

    return SizedBox(
      height: 190,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: preview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final recommendation = preview[index];
          final organization = recommendation.organization;

          return _HomeOrganizationCard(
            organization: organization,
            onTap: () => _openOrganization(context, organization),
          );
        },
      ),
    );
  }

  Widget _buildCourses(BuildContext context) {
    if (state.coursesError != null) {
      return const SizedBox.shrink();
    }

    final recommendations = state.recommendedCourses ?? [];

    if (recommendations.isEmpty) {
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
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          final course = recommendation.course;

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
                ..add(GetOrganizationDetailsEvent(organization.slug)),
          child: OrganizationDetailsPage(slug: organization.slug),
        ),
      ),
    );
  }

  Future<void> _openCourse(BuildContext context, CourseEntity course) async {
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

  const _FeaturedCourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;

    final isEnrolled = course.enrollment != null;
    final isCompleted = course.isCompleted;
    final progress = course.enrollment?.progressPercentage ?? 0;
    final organizationName = course.organizationDisplayName;

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
                  errorBuilder: (_, __, ___) => _fallbackBackground(),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            isCompleted
                                ? 'مكتملة بالكامل'
                                : isEnrolled
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

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (organizationName != null) ...[
                                Text(
                                  organizationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),

                    if (isEnrolled) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (progress / 100).clamp(0, 1),
                          minHeight: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.22),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isCompleted
                            ? 'مكتملة بالكامل'
                            : '${progress.toStringAsFixed(0)}٪ مكتمل',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
        child: Icon(Icons.menu_book_rounded, color: Colors.white24, size: 80),
      ),
    );
  }
}

class _HomeOrganizationCard extends StatelessWidget {
  final OrganizationEntity organization;
  final VoidCallback onTap;

  const _HomeOrganizationCard({required this.organization, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPrivate = organization.visibility == OrganizationVisibility.private;
    final hasImage = organization.image != null && organization.image!.isNotEmpty;

    final visibilityColor = isPrivate
        ? (isDark ? const Color(0xffFBBF24) : const Color(0xffB4780F))
        : (isDark ? const Color(0xff86EFAC) : const Color(0xff2E7D53));

    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.secondaryContainer.withValues(alpha: 0.3)
                  : AppColors.lavenderLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? colors.secondary.withValues(alpha: 0.3)
                    : AppColors.lavender.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: hasImage
                            ? null
                            : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.lavender.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? Image.network(
                        organization.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _initials(),
                      )
                          : _initials(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
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

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        organization.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (organization.verified)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: Color(0xff0EA5E9),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      isPrivate ? Icons.lock_outline_rounded : Icons.public_rounded,
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
                      Icon(Icons.people_alt_outlined, size: 13, color: colors.onSurfaceVariant),
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
                if (organization.description != null && organization.description!.isNotEmpty) ...[
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
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
      ),
    );
  }
}
class _HomeCourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const _HomeCourseCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;
    final isEnrolled = course.enrollment != null;
    final isCompleted = course.isCompleted;
    final progress = course.enrollment?.progressPercentage ?? 0;
    final organizationName = course.organizationDisplayName;

    return SizedBox(
      width: 235,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colors.primaryContainer.withValues(alpha: 0.25)
                  : AppColors.primaryLight.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? colors.primary.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      else
                        _placeholder(),
                      if (isCompleted)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xff2E7D53),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                                SizedBox(width: 3),
                                Text('مكتملة', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        if (organizationName != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            organizationName,
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
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (progress / 100).clamp(0, 1),
                              minHeight: 5,
                              backgroundColor: colors.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(
                                isCompleted ? const Color(0xff2E7D53) : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isCompleted ? 'مكتملة بالكامل' : '${progress.toStringAsFixed(0)}٪ مكتمل',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? const Color(0xff2E7D53) : colors.onSurfaceVariant,
                            ),
                          ),
                        ] else
                          Row(
                            children: [
                              Text('استكشف الكورس', style: TextStyle(color: colors.primary, fontSize: 10.5, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 3),
                              Icon(Icons.arrow_forward_rounded, size: 14, color: colors.primary),
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
        child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 38),
      ),
    );
  }
}
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: colors.onSurfaceVariant),
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

  const _RetryCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

class _NotificationRefreshListener extends StatefulWidget {
  final Widget child;

  const _NotificationRefreshListener({required this.child});

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

    final firebaseMessagingService = sl<FirebaseMessagingService>();
    _subscription ??= firebaseMessagingService.foregroundMessages.listen((_) {
      _notificationsBloc.add(NotificationReceivedEvent());
      _refreshNotifications(keepHigherUnreadCount: true);

      _delayedRefresh?.cancel();
      _delayedRefresh = Timer(
        const Duration(milliseconds: 1200),
        () => _refreshNotifications(keepHigherUnreadCount: true),
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

  void _refreshNotifications({bool keepHigherUnreadCount = false}) {
    if (!mounted) return;

    _notificationsBloc.add(
      RefreshNotificationsEvent(keepHigherUnreadCount: keepHigherUnreadCount),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: 'الرسائل',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<ChatBloc>()..add(LoadChatsEvent()),
                  child: const ChatsPage(),
                ),
              ),
            );
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: isDark ? 0.72 : 0.88),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: colors.outlineVariant.withValues(
                  alpha: isDark ? 0.28 : 0.45,
                ),
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: colors.onSurfaceVariant,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        final unreadCount = state is NotificationsLoaded
            ? state.unreadCount
            : 0;

        final inviteCount = state is NotificationsLoaded
            ? state.invites.length
            : 0;

        final badgeCount = unreadCount > inviteCount
            ? unreadCount
            : inviteCount;

        final hasBadge = badgeCount > 0;

        final activeColor = isDark ? AppColors.primaryLight : colors.primary;

        final backgroundColor = hasBadge
            ? activeColor.withValues(alpha: isDark ? 0.16 : 0.10)
            : colors.surface.withValues(alpha: isDark ? 0.72 : 0.88);

        final borderColor = hasBadge
            ? activeColor.withValues(alpha: isDark ? 0.30 : 0.22)
            : colors.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.45);

        final iconColor = hasBadge ? activeColor : colors.onSurfaceVariant;

        return Tooltip(
          message: 'الإشعارات',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                final notificationsBloc = context.read<NotificationsBloc>()
                  ..add(RefreshNotificationsEvent());

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: notificationsBloc,
                      child: const NotificationsPage(),
                    ),
                  ),
                );

                if (context.mounted) {
                  context.read<NotificationsBloc>().add(
                    RefreshNotificationsEvent(),
                  );
                }
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: borderColor),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        hasBadge
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_rounded,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        top: 3,
                        left: 3,
                        child: _NotificationBadge(count: badgeCount),
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

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 20,
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.surface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.14),
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
