import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../bloc/roadmap_bloc.dart';
import '../bloc/roadmap_event.dart';
import '../bloc/roadmap_state.dart';
import '../widgets/roadmap_card.dart';
import 'roadmap_details_page.dart';

class MyRoadmapsPage extends StatelessWidget {
  const MyRoadmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<RoadmapBloc>()..add(LoadMyRoadmaps()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: BlocBuilder<RoadmapBloc, RoadmapState>(
            builder: (context, state) {
              if (state is RoadmapLoading || state is RoadmapInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is RoadmapError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<RoadmapBloc>().add(LoadMyRoadmaps()),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }
              if (state is RoadmapsLoaded) {
                if (state.roadmaps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.map_outlined, size: 46, color: colors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لم تتابع أي مسار بعد',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
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
                      return RoadmapCard(
                        roadmap: roadmap,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoadmapDetailsPage(
                                slug: orgSlug,
                                roadmapId: roadmap.id,
                              ),
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