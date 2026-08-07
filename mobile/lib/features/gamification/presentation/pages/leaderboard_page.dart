import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GamificationBloc>()..add(LoadLeaderboard(period: 'WEEKLY')),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatefulWidget {
  const _LeaderboardView();

  @override
  State<_LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<_LeaderboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final period = _tabController.index == 0 ? 'WEEKLY' : 'MONTHLY';
        context.read<GamificationBloc>().add(LoadLeaderboard(period: period));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المتصدرين'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'أسبوعي'),
            Tab(text: 'شهري'),
          ],
        ),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state is GamificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GamificationError) {
            return Center(child: Text(state.message));
          }
          if (state is LeaderboardLoaded) {
            return _LeaderboardList(leaderboard: state.leaderboard);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final dynamic leaderboard;

  const _LeaderboardList({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    if (leaderboard.leaders.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.leaders.length,
      itemBuilder: (context, index) {
        final entry = leaderboard.leaders[index];
        final isMe = leaderboard.me != null && entry.userId == leaderboard.me.userId;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryLight : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isMe
                ? Border.all(color: AppColors.primary, width: 1.5)
                : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: entry.rank <= 3 ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: entry.userPicture != null && entry.userPicture!.isNotEmpty
                    ? NetworkImage(entry.userPicture!)
                    : null,
                child: entry.userPicture == null || entry.userPicture!.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),

              // Name & Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'المستوى ${entry.level}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // XP
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.xp} XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),

              if (isMe) ...[
                const SizedBox(width: 8),
                const Icon(Icons.star, color: AppColors.primary, size: 18),
              ],
            ],
          ),
        );
      },
    );
  }
}