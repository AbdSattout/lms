import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_card.dart';
import 'post_details_page.dart';

class OrganizationPostsPage extends StatelessWidget {
  final String orgSlug;
  final bool isMember;

  const OrganizationPostsPage({
    super.key,
    required this.orgSlug,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PostsBloc>()..add(LoadOrganizationPosts(orgSlug)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('منشورات المنظمة')),
          body: BlocBuilder<PostsBloc, PostsState>(
            builder: (context, state) {
              if (state is PostsLoading || state is PostsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PostsError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<PostsBloc>().add(LoadOrganizationPosts(orgSlug)),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }
              if (state is PostsLoaded) {
                if (state.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('لا توجد منشورات حالياً', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<PostsBloc>().add(RefreshPosts()),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        post: post,
                        onTap: () async {
                          if (!isMember) {
                            _showMembershipRequiredDialog(context);
                            return;
                          }
                          final updatedPost = await Navigator.push<PostEntity>(
                            context,
                            MaterialPageRoute(builder: (_) => PostDetailsPage(post: post)),
                          );
                          if (updatedPost != null && context.mounted) {
                            context.read<PostsBloc>().add(UpdatePostInList(updatedPost));
                          }
                        },
                        onCommentTap: () async {
                          if (!isMember) {
                            _showMembershipRequiredDialog(context);
                            return;
                          }
                          final updatedPost = await Navigator.push<PostEntity>(
                            context,
                            MaterialPageRoute(builder: (_) => PostDetailsPage(post: post, openComments: true)),
                          );
                          if (updatedPost != null && context.mounted) {
                            context.read<PostsBloc>().add(UpdatePostInList(updatedPost));
                          }
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
  void _showMembershipRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('انضم إلى المنظمة'),
            ],
          ),
          content: const Text(
            'لرؤية تفاصيل المنشورات والتفاعل معها، يجب أن تكون عضواً في هذه المنظمة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<OrganizationDetailsBloc>()
                          ..add(GetOrganizationDetailsEvent(orgSlug)),
                        child: OrganizationDetailsPage(slug: orgSlug),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(

                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('الانضمام إلى المنظمة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}