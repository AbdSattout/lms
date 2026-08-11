import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../domain/entities/post_entity.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_card.dart';
import 'post_details_page.dart';

class CoursePostsPage extends StatelessWidget {
  final int courseId;
  const CoursePostsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        if (courseId.isNaN) {
          return sl<PostsBloc>();
        }
        return sl<PostsBloc>()..add(LoadCoursePosts(courseId));
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('منشورات الكورس')),
          body: courseId.isNaN
              ? Center(
            child: Text(
              'معرف الكورس غير متوفر',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          )
              : BlocBuilder<PostsBloc, PostsState>(
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
                        onPressed: () {
                          context.read<PostsBloc>().add(LoadCoursePosts(courseId));
                        },
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
                          final updatedPost = await Navigator.push<PostEntity>(
                            context,
                            MaterialPageRoute(builder: (_) => PostDetailsPage(post: post)),
                          );
                          if (updatedPost != null && context.mounted) {
                            context.read<PostsBloc>().add(UpdatePostInList(updatedPost));
                          }
                        },
                        onCommentTap: () async {
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
}