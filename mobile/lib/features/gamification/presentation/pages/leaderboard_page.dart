import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../bloc/gamification_bloc.dart';
import '../bloc/gamification_event.dart';
import '../bloc/gamification_state.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<GamificationBloc>()..add(LoadLeaderboard(period: 'WEEKLY')),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('لوحة المتصدرين'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: colors.onPrimary,
                unselectedLabelColor: colors.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'أسبوعي'),
                  Tab(text: 'شهري'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          if (state is GamificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GamificationError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final period = _tabController.index == 0
                          ? 'WEEKLY'
                          : 'MONTHLY';
                      context.read<GamificationBloc>().add(
                        LoadLeaderboard(period: period),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is LeaderboardLoaded) {
            return _LeaderboardContent(leaderboard: state.leaderboard);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  final LeaderboardEntity leaderboard;

  const _LeaderboardContent({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final leaders = leaderboard.leaders;
    final me = leaderboard.me;

    if (leaders.isEmpty) {
      return const Center(child: Text('لا توجد بيانات للمتصدرين'));
    }

    return Column(
      children: [
        if (leaders.length >= 3)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: _Podium(leaders: leaders.take(3).toList()),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: leaders.length,
            itemBuilder: (context, index) {
              final entry = leaders[index];
              final isMe = me != null && entry.userId == me.userId;
              if (leaders.length >= 3 && index < 3) {
                return const SizedBox.shrink();
              }
              return _LeaderboardTile(entry: entry, isMe: isMe);
            },
          ),
        ),
        if (me != null && !leaders.any((e) => e.userId == me.userId))
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: _LeaderboardTile(entry: me, isMe: true),
          ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntryEntity> leaders;
  const _Podium({required this.leaders});

  @override
  Widget build(BuildContext context) {
    if (leaders.length < 3) return const SizedBox.shrink();

    final first = leaders[0];
    final second = leaders[1];
    final third = leaders[2];

    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumCard(entry: second, rank: 2, height: 120)),
          Expanded(child: _PodiumCard(entry: first, rank: 1, height: 160)),
          Expanded(child: _PodiumCard(entry: third, rank: 3, height: 100)),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final int rank;
  final double height;

  const _PodiumCard({
    required this.entry,
    required this.rank,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final medalColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ResilientNetworkAvatar(
            radius: 24,
            imageUrl: entry.picture,
            fallbackLabel: entry.name,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 6),
          Text(
            entry.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${entry.xp} XP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  medalColors[rank - 1].withValues(alpha: 0.8),
                  medalColors[rank - 1].withValues(alpha: 0.3),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final bool isMe;

  const _LeaderboardTile({required this.entry, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rank = entry.rank;
    final levelLabel = _levelLabel(entry);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? colors.primary.withValues(alpha: 0.08) : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              rank == null ? '-' : '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: rank != null && rank <= 3
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ResilientNetworkAvatar(
            radius: 20,
            imageUrl: entry.picture,
            fallbackLabel: entry.name,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  levelLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isMe
                  ? colors.primary.withValues(alpha: 0.15)
                  : colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${entry.xp} XP',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: colors.primary,
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.amber.shade600, size: 18),
          ],
        ],
      ),
    );
  }
}

String _levelLabel(LeaderboardEntryEntity entry) {
  final title = entry.levelTitle?.trim();
  final hasTitle = title != null && title.isNotEmpty;

  if (entry.levelNumber == null && !hasTitle) {
    return 'لم يبدأ بعد';
  }

  if (entry.levelNumber == null) {
    return title!;
  }

  if (!hasTitle) {
    return 'المستوى ${entry.levelNumber}';
  }

  return 'المستوى ${entry.levelNumber} · $title';
}
