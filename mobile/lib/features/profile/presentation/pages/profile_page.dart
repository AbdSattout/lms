import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/databases/cache/cache_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/telegram_login_page.dart';
import '../../domain/entities/profile_entity.dart';
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

            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم تحديث البيانات بنجاح',
                  ),
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

                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(35),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: -55,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 55,
                                      backgroundImage:
                                      profile.user.picture.isNotEmpty
                                          ? NetworkImage(profile.user.picture)
                                          : const AssetImage(
                                        'assets/images/user.png',
                                      ) as ImageProvider,
                                    ),

                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _pickImage(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 70),

                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dark,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        profile.email ?? "لم يتم إضافة البريد الإلكتروني",
                        style: const TextStyle(
                          color: AppColors.darkSoft,
                        ),
                      ),

                      const SizedBox(height: 24),

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
                          _showEditProfileSheet(
                            context,
                            profile,
                          );
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
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text(
                                'تسجيل الخروج',
                              ),
                              content: const Text(
                                'هل أنت متأكد؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('إلغاء'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await sl<CacheHelper>().removeData(
                                      key: "CachedAuthToken",
                                    );

                                    if (!context.mounted) return;

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                        const TelegramLoginPage(),
                                      ),
                                          (route) => false,
                                    );
                                  },
                                  child: const Text('خروج'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  )

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
    margin: const EdgeInsets.only(
      bottom: 14,
    ),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
            AppColors.primary.withOpacity(
              0.1,
            ),
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
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
                value.isEmpty
                    ? "غير مضاف"
                    : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w700,
                  color: value.isEmpty
                      ? Colors.grey
                      : AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
void _showEditProfileSheet(
    BuildContext context,
    ProfileEntity profile,
    ) {
  final emailController =
  TextEditingController(
    text: profile.email ?? '',
  );

  final phoneController =
  TextEditingController(
    text: profile.phone ?? '',
  );

  final universityController =
  TextEditingController(
    text: profile.university ?? '',
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom:
          MediaQuery.of(context)
              .viewInsets
              .bottom +
              20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "تعديل الملف الشخصي",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني",
                  hintText: "example@gmail.com"
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                hintText: "09XXXXXXXX"
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: universityController,
              decoration: const InputDecoration(
                labelText: "الجامعة",
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {

                  context.read<ProfileBloc>().add(
                    UpdateProfileEvent(
                      email: emailController.text,
                      phone: phoneController.text,
                      university: universityController.text,
                    ),
                  );

                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  "حفظ التعديلات",
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
Future<void> _pickImage(
    BuildContext context,
    ) async {

  final ImagePicker picker =
  ImagePicker();

  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70,
  );

  if (image == null) return;

  context.read<ProfileBloc>().add(
    UpdateProfilePictureEvent(
      image.path,
    ),
  );
}