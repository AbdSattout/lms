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

class _ProfilePageState
    extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();

    context.read<ProfileBloc>().add(
      GetProfileEvent(),
    );
  }

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

              final profile =
                  state.profile;

              return SafeArea(
                child:
                SingleChildScrollView(
                  child: Column(
                    children: [

                      const SizedBox(
                        height: 40,
                      ),

                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profile.picture != null && profile.picture.toString().startsWith('http')
                            ? NetworkImage(profile.picture)
                            : const AssetImage('assets/images/user.png') as ImageProvider,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      /*TextButton.icon(
                        onPressed: () {
                          context
                              .read<
                              ProfileBloc>()
                              .add(
                            PickAndUploadPictureEvent(),
                          );
                        },

                        icon: const Icon(
                          Icons.camera_alt,
                        ),

                        label: const Text(
                          "تغيير الصورة",
                        ),
                      ),*/

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        profile.name,

                        style:
                        const TextStyle(
                          fontSize: 26,
                          fontWeight:
                          FontWeight.w900,
                          color:
                          AppColors.dark,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      if (profile.email!.isNotEmpty)
                        Text(
                          profile.email!,
                          style:
                          const TextStyle(
                            color: AppColors
                                .darkSoft,
                          ),
                        ),

                      if (profile.phone!
                          .isNotEmpty)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 6,
                          ),

                          child: Text(
                            profile.phone!,
                            style:
                            const TextStyle(
                              color: AppColors
                                  .darkSoft,
                            ),
                          ),
                        ),

                      if (profile.university !=
                          null)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 6,
                          ),

                          child: Text(
                            profile.university!,
                            style:
                            const TextStyle(
                              color: AppColors
                                  .darkSoft,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: 40,
                      ),

                      ProfileOptionTile(
                        title:
                        "الإعدادات الشخصية",

                        icon:
                        Icons.settings_outlined,

                        onTap: () {},
                      ),

                      ProfileOptionTile(
                        title: "المظهر",

                        icon:
                        Icons.palette_outlined,

                        onTap: () {},
                      ),

                      ProfileOptionTile(
                        title: "شهاداتي",

                        icon: Icons
                            .workspace_premium_outlined,

                        onTap: () {},
                      ),

                      ProfileOptionTile(
                        title:
                        "تسجيل الخروج",

                        icon:
                        Icons.logout_rounded,

                        destructive: true,

                        onTap: () {
                          // TODO Logout
                        },
                      ),

                      const SizedBox(
                        height: 120,
                      ),
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