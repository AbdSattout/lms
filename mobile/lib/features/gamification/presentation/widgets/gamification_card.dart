import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';
import '../pages/leaderboard_page.dart';

class GamificationCard extends StatelessWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(LoadGamificationData()),
      child: const _GamificationCardContent(),
    );
  }
}

class _GamificationCardContent extends StatelessWidget {
  const _GamificationCardContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamificationBloc, GamificationState>(
      builder: (context, state) {
        if (state is GamificationLoading) {
          return const _LoadingCard();
        }
        if (state is GamificationError) {
          return _ErrorCard(message: state.message);
        }
        if (state is GamificationLoaded) {
          return _LoadedCard(
            progress: state.progress,
            streak: state.streak,
            latestActivity: state.activities.isNotEmpty ? state.activities.first : null,
          );
        }
        return const _LoadingCard();
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _LoadedCard extends StatelessWidget {
  final dynamic progress;
  final dynamic streak;
  final dynamic latestActivity;

  const _LoadedCard({
    required this.progress,
    required this.streak,
    this.latestActivity,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تقدم التعلم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'المستوى ${progress.levelNumber}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              progress.levelTitle,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // XP Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.progressPercentage / 100,
                minHeight: 10,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.totalXp} XP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  '${progress.xpToNextLevel} XP للمستوى التالي',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Streak info
            Row(
              children: [
                _StreakBadge(
                  icon: Icons.local_fire_department,
                  value: '${streak.currentStreak}',
                  label: 'اليوم',
                  color: Colors.orange,
                ),
                const SizedBox(width: 16),
                _StreakBadge(
                  icon: Icons.emoji_events,
                  value: '${streak.longestStreak}',
                  label: 'الأطول',
                  color: Colors.amber,
                ),
                const SizedBox(width: 16),
                _StreakBadge(
                  icon: Icons.calendar_month,
                  value: '${streak.activeDays}',
                  label: 'نشط',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Today's activity
            if (latestActivity != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'نشاط اليوم',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _ActivityChip(label: '${latestActivity.xpEarned} XP', icon: Icons.star),
                  _ActivityChip(label: '${latestActivity.completedBlocks} تمارين', icon: Icons.grid_view),
                  _ActivityChip(label: '${latestActivity.completedLessons} دروس', icon: Icons.menu_book),
                  _ActivityChip(label: '${latestActivity.totalActions} نشاط', icon: Icons.bolt),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Leaderboard button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                  );
                },
                icon: const Icon(Icons.leaderboard_rounded, size: 18),
                label: const Text('لوحة المتصدرين'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StreakBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ActivityChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}