import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/roadmap_bloc.dart';
import '../bloc/roadmap_event.dart';
import '../bloc/roadmap_state.dart';
import 'roadmap_details_page.dart';

class MyRoadmapsPage extends StatelessWidget {
  const MyRoadmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoadmapBloc>()..add(LoadMyRoadmaps()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('مساراتي')),
          body: BlocBuilder<RoadmapBloc, RoadmapState>(
            builder: (context, state) {
              if (state is RoadmapLoading || state is RoadmapInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is RoadmapError) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<RoadmapBloc>().add(LoadMyRoadmaps()),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ]),
                );
              }
              if (state is RoadmapsLoaded) {
                if (state.roadmaps.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.map_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('لم تتابع أي مسار بعد', style: TextStyle(fontSize: 24,color: Theme.of(context).colorScheme.primary)),
                    ]),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<RoadmapBloc>().add(LoadMyRoadmaps()),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.roadmaps.length,
                    itemBuilder: (context, index) {
                      final roadmap = state.roadmaps[index];
                      final orgSlug = roadmap.organization?.slug ?? '';
                      return _MyRoadmapCard(
                        roadmap: roadmap,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoadmapDetailsPage(slug: orgSlug, roadmapId: roadmap.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class _MyRoadmapCard extends StatelessWidget {
  final dynamic roadmap;
  final VoidCallback onTap;
  const _MyRoadmapCard({required this.roadmap, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final courseCount = roadmap.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.map_outlined, color: colors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(roadmap.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
                  if (roadmap.organization != null) ...[
                    const SizedBox(height: 4),
                    Text(roadmap.organization.name, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.menu_book_rounded, size: 14, color: colors.primary),
                    const SizedBox(width: 4),
                    Text('$courseCount ${courseCount == 1 ? 'كورس' : 'كورسات'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                  ]),
                ]),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}