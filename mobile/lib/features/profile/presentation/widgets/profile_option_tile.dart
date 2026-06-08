import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileOptionTile
    extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  const ProfileOptionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color:
              Colors.grey.withOpacity(
                0.08,
              ),
              blurRadius: 10,
              offset: const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: ListTile(
          onTap: onTap,

          leading: Container(
            padding:
            const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: destructive
                  ? Colors.red
                  .withOpacity(
                0.1,
              )
                  : AppColors.primary
                  .withOpacity(
                0.1,
              ),

              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,

              size: 22,

              color: destructive
                  ? Colors.red
                  : AppColors.primary,
            ),
          ),

          title: Text(
            title,

            style: TextStyle(
              fontWeight:
              FontWeight.bold,

              color: destructive
                  ? Colors.red
                  : AppColors.dark,
            ),
          ),

          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.darkSoft,
          ),
        ),
      ),
    );
  }
}