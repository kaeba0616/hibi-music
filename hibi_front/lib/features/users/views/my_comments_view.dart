import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../mocks/my_comments_mock.dart';
import '../viewmodels/my_comments_viewmodel.dart';

/// MP-01: 내가 쓴 댓글 목록 화면
class MyCommentsView extends ConsumerStatefulWidget {
  const MyCommentsView({super.key});

  @override
  ConsumerState<MyCommentsView> createState() => _MyCommentsViewState();
}

class _MyCommentsViewState extends ConsumerState<MyCommentsView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 댓글 목록 로드
    Future.microtask(() {
      ref.read(myCommentsProvider.notifier).loadMyComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myCommentsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('내가 쓴 댓글'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MyCommentsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(state.error!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(myCommentsProvider.notifier).loadMyComments();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '아직 작성한 댓글이 없어요',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.comments.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _MyCommentTile(myComment: state.comments[index]);
      },
    );
  }
}

class _MyCommentTile extends StatelessWidget {
  final MyComment myComment;

  const _MyCommentTile({required this.myComment});

  @override
  Widget build(BuildContext context) {
    final comment = myComment.comment;
    final songInfo = myComment.songInfo;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        comment.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(Icons.music_note, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${songInfo.songTitle} - ${songInfo.artistName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(comment.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        // 해당 곡 상세 페이지로 이동
        context.push('/song/${songInfo.songId}');
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
