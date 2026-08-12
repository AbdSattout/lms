import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/roadmap_bloc.dart';
import '../bloc/roadmap_event.dart';
import '../bloc/roadmap_state.dart';
import 'roadmap_details_page.dart';

class OrganizationRoadmapsPage extends StatelessWidget {
  final String slug;
  const OrganizationRoadmapsPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoadmapBloc>()..add(LoadOrganizationRoadmaps(slug)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('المسارات التعليمية')),
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
                      onPressed: () => context.read<RoadmapBloc>().add(LoadOrganizationRoadmaps(slug)),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ]),
                );
              }
              if (state is RoadmapsLoaded) {
                if (state.roadmaps.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.map_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('لا توجد مسارات تعليمية حالياً', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ]),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.roadmaps.length,
                  itemBuilder: (context, index) {
                    final roadmap = state.roadmaps[index];
                    return _RoadmapCard(
                      roadmap: roadmap,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RoadmapDetailsPage(slug: slug, roadmapId: roadmap.id),
                          ),
                        );
                      },
                    );
                  },
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

class _RoadmapCard extends StatelessWidget {
  final dynamic roadmap;
  final VoidCallback onTap;
  const _RoadmapCard({required this.roadmap, required this.onTap});

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
                  if (roadmap.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(roadmap.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.menu_book_rounded, size: 14, color: colors.primary),
                    const SizedBox(width: 4),
                    Text('$courseCount ${courseCount == 1 ? 'كورس' : 'كورسات'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
                    if (roadmap.followStatus == 'FOLLOWING') ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xff2E7D53).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('متابَع', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xff2E7D53))),
                      ),
                    ],
                  ]),
                ]),
              ),
              Icon(Icons.arrow_back_ios_rounded, size: 14, color: colors.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}