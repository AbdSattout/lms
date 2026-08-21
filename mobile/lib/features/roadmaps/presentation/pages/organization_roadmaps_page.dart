import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/roadmap_bloc.dart';
import '../bloc/roadmap_event.dart';
import '../bloc/roadmap_state.dart';
import '../widgets/roadmap_card.dart';
import 'roadmap_details_page.dart';

class OrganizationRoadmapsPage extends StatelessWidget {
  final String slug;
  const OrganizationRoadmapsPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<RoadmapBloc>()..add(LoadOrganizationRoadmaps(slug)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 28,
                  left: 22,
                  right: 22,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      colors.secondaryContainer.withValues(alpha: 0.4),
                      colors.primaryContainer.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(34),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: colors.primary,
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المسارات التعليمية',
                            style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'خطط تعلم منظمة تساعدك على الوصول لهدفك',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<RoadmapBloc, RoadmapState>(
                  builder: (context, state) {
                    if (state is RoadmapLoading || state is RoadmapInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is RoadmapError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: colors.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<RoadmapBloc>().add(
                                LoadOrganizationRoadmaps(slug),
                              ),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is RoadmapsLoaded) {
                      if (state.roadmaps.isEmpty) {
                        return _EmptyRoadmapsState();
                      }
                      return RefreshIndicator(
                        onRefresh: () async => context.read<RoadmapBloc>().add(
                          LoadOrganizationRoadmaps(slug),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.roadmaps.length,
                          itemBuilder: (context, index) {
                            final roadmap = state.roadmaps[index];
                            return RoadmapCard(
                              roadmap: roadmap,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RoadmapDetailsPage(
                                      slug: slug,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRoadmapsState extends StatelessWidget {
  const _EmptyRoadmapsState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
            child: Icon(
              Icons.map_outlined,
              size: 46,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مسارات تعليمية بعد',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'استكشف المنظمة لاحقاً للعثور على مسارات جديدة',
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}