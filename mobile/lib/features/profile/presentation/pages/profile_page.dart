import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_option_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return BlocListener<
        ProfileBloc,
        ProfileState>(
      listener: (context, state) {

        if (state is ProfilePictureUpdated) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'تم تحديث الصورة بنجاح',
              ),
            ),
          );
        }

        if (state is ProfileError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                state.message,
              ),
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor:
        const Color(0xffF8F9FA),

        body: BlocBuilder<
            ProfileBloc,
            ProfileState>(
          builder: (context, state) {

            if (state is ProfileLoading) {
              return const Center(
                child:
                CircularProgressIndicator(),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,
                ),
              );
            }

            if (state is ProfileLoaded) {
              final profile = state.profile;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                        profile.user.picture.isNotEmpty &&
                            profile.user.picture.startsWith('http')
                            ? NetworkImage(profile.user.picture)
                            : const AssetImage(
                          'assets/images/user.png',
                        ) as ImageProvider,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dark,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildInfoCard(
                        title: "البريد الإلكتروني",
                        value: profile.email ?? "",
                        icon: Icons.email_outlined,
                      ),

                      _buildInfoCard(
                        title: "رقم الهاتف",
                        value: profile.phone ?? "",
                        icon: Icons.phone_outlined,
                      ),

                      _buildInfoCard(
                        title: "الجامعة",
                        value: profile.university ?? "",
                        icon: Icons.school_outlined,
                      ),

                      const SizedBox(height: 30),

                      ProfileOptionTile(
                        title: "الإعدادات الشخصية",
                        icon: Icons.edit_outlined,
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(
                                profile: profile,
                              ),
                            ),
                          );*/
                        },
                      ),

                      ProfileOptionTile(
                        title: "المظهر",
                        icon: Icons.palette_outlined,
                        onTap: () {},
                      ),

                      ProfileOptionTile(
                        title: "شهاداتي",
                        icon: Icons.workspace_premium_outlined,
                        onTap: () {},
                      ),

                      ProfileOptionTile(
                        title: "تسجيل الخروج",
                        icon: Icons.logout_rounded,
                        destructive: true,
                        onTap: () {
                          // logout logic
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
Widget _buildInfoCard({
  required String title,
  required String value,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkSoft,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value.isEmpty ? "غير مضاف" : value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}