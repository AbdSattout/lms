import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import 'package:lms/features/home/bloc/navbar_cubit.dart';

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
                  const Center(child: Text('كورساتي', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  const Center(child: Text('المنظمات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))), 
                  ProfileView(user: user),
                ],
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
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAvatar(user, radius: 24, isHome: true),
                      const SizedBox(width: 12),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff040415)),
                      ),
                    ],
                  ),
                  const Text(
                    "أهلا بعودتك",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xff040415)),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100, // نفس لون E-Shop
                        hintText: "ابحث عن مسار، كورس...",
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        // الحدود عند عدم الضغط
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                        // الحدود عند الضغط (أبيض عريض)
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // أيقونة الفلتر
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xff040415),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Image.asset('assets/icons/filter.png', color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hero Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff040415), Color(0xff1A1A2E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xffff8900), borderRadius: BorderRadius.circular(8)),
                      child: const Text("جديد", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    const Text("طور مهاراتك البرمجية", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("استكشف أحدث الكورسات الآن", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
            backgroundColor: const Color(0xff040415),
            // 🔥 سر الاختفاء: جعل لون الـ Snake نفس لون خلفية الـ Navbar
            snakeViewColor: const Color(0xff040415), 
            height: 70,
            elevation: 4,
            // ⚪️ لون النص المختار (أبيض كما طلبت)
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: state,
            onTap: (index) {
              context.read<NavbarCubit>().controller.animateToPage(
                index, duration: const Duration(milliseconds: 400), curve: Curves.linear,
              );
              context.read<NavbarCubit>().update(index);
            },
            items: [
              _buildNavItem('assets/navbar_icons/home.png', 'الرئيسية'),
              _buildNavItem('assets/navbar_icons/categories.png', 'منظمات'),
              _buildNavItem('assets/navbar_icons/book.png', 'الكورسات'),
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
      activeIcon: const Padding(
        padding: EdgeInsets.all(5.0),
        child: CircleAvatar(
          backgroundColor: Color(0xffff8900), 
          radius: 4,
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
        border: Border.all(color: const Color(0xffff8900), width: isHome ? 2 : 4),
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
            child: Icon(iconData, color: isDestructive ? Colors.red : const Color(0xffff8900), size: 22),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : const Color(0xff040415))),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          onTap: () {},
        ),
      ),
    );
  }
}