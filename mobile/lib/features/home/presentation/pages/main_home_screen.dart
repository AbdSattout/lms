import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import 'package:lms/features/home/bloc/navbar_cubit.dart';
import 'package:lms/features/profile/presentation/pages/profile_page.dart';

import '../../../courses/presentation/bloc/my_courses_bloc.dart';
import '../../../courses/presentation/bloc/my_courses_event.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../organizations/presentation/bloc/organization_bloc.dart';
import '../../../organizations/presentation/bloc/organization_event.dart';
import '../../../organizations/presentation/pages/organizations_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
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
          backgroundColor: const Color(0xffF8F9FA),
          extendBody: true,
          body: BlocBuilder<NavbarCubit, int>(
            builder: (context, state) {
              return PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: context.read<NavbarCubit>().controller,
                children: [
                  _buildHomeContent(context, user),
                  BlocProvider(
                    create: (_) => sl<MyCoursesBloc>()..add(GetMyEnrollmentsEvent()),
                    child: const MyCoursesPage(),
                  ),
                  BlocProvider(
                    create: (_) => sl<OrganizationBloc>()..add(GetAllOrganizationsEvent()),
                    child: const OrganizationsPage(),
                  ),
                  BlocProvider(
                    create: (_) => sl<ProfileBloc>()
                      ..add(GetProfileEvent()),
                    child: const ProfilePage(),
                  )],
              );
            },
          ),
          bottomNavigationBar: _buildSnakeBar(),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, dynamic user) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
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

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  Container(
                    padding: const EdgeInsets.all(11),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.dark,
                      size: 24,
                    ),
                  ),

                  Row(
                    children: [

                      Text(
                        "مسار",

                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 14),

                      _buildAvatar(
                        user,
                        radius: 23,
                        isHome: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 35),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -18),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),

                child: Row(
                  children: [

                    Expanded(
                      child: Container(
                        height: 60,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),

                        child: const TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,

                            hintText:
                            'ابحث عن كورس أو مسار...',

                            prefixIcon: Icon(
                              Icons.search_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      width: 60,
                      height: 60,

                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "الكورسات المميزة",

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),

                  Text(
                    "عرض الكل",

                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Hero Card
          SliverToBoxAdapter(
            child: _buildFeaturedCourse(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                14,
              ),

              child: const Text(
                "استكشف الكورسات",

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                itemCount: 5,

                itemBuilder: (context, index) {
                  return Container(
                    width: 190,
                    margin: const EdgeInsets.only(left: 14),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Container(
                            height: 100,

                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Flutter",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "ابدأ بتطوير التطبيقات",

                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
  Widget _buildFeaturedCourse() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGE
            Stack(
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),

                  // child: Image.asset(
                  //   'assets/images/course.png',
                  //   height: 180,
                  //   width: double.infinity,
                  //   fit: BoxFit.cover,
                  // ),
                ),

                Positioned(
                  top: 14,
                  left: 14,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: const Row(
                      children: [

                        CircleAvatar(
                          radius: 4,
                          backgroundColor: Color(0xffff8900),
                        ),

                        SizedBox(width: 6),

                        Text(
                          "منشور",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(22),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "أساسيات البرمجة للمبتدئين",

                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff040415),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "دورة تفاعلية مصممة لتبسيط المفاهيم البرمجية المعقدة بأسلوب ممتع وعملي بالتحديات.",

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Divider(
                    color: Colors.grey.shade200,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xffff8900)
                              .withOpacity(0.12),

                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: const Row(
                          children: [

                            Icon(
                              Icons.menu_book_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),

                            SizedBox(width: 6),

                            Text(
                              "تسجيل",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "124 طالب",

                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
            backgroundColor: Colors.white,
            snakeViewColor: AppColors.primary.withOpacity(0.10),
            height: 70,
            elevation: 10,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.darkSoft.withOpacity(0.55),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: state,
            onTap: (index) {
              context.read<NavbarCubit>().controller.animateToPage(
                index, duration: const Duration(milliseconds: 100), curve: Curves.linear,
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
          color: AppColors.primary.withOpacity(0.12),
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

  static Widget _buildAvatar(dynamic user, {required double radius, bool isHome = false}) {
    bool hasValidImage = user.picture != null && user.picture.toString().startsWith('http');
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: isHome ? 2 : 4),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: hasValidImage
            ? NetworkImage(user.picture)
            : const AssetImage('assets/images/user.png') as ImageProvider,
      ),
    );
  }
}


class ProfileView extends StatelessWidget {
  final dynamic user;
  const ProfileView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            MainHomeScreen._buildAvatar(user, radius: 55),
            const SizedBox(height: 20),
            Text(
              user.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xff040415)),
            ),
            const SizedBox(height: 40),
            _buildProfileOption(title: "الإعدادات الشخصية", iconData: Icons.settings_outlined),
            _buildProfileOption(title: "المظهر", iconData: Icons.palette_outlined),
            _buildProfileOption(title: "شهاداتي", iconData: Icons.workspace_premium_outlined),
            _buildProfileOption(title: "تسجيل الخروج", iconData: Icons.logout_rounded, isDestructive: true),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({required String title, required IconData iconData, bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xffff8900).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: isDestructive ? Colors.red : AppColors.primary, size: 22),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : AppColors.dark)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.darkSoft),
          onTap: () {},
        ),
      ),
    );
  }
}