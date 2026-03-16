import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/posts/viewmodels/post_list_viewmodel.dart';
import 'package:hidi/features/posts/viewmodels/post_viewmodel.dart';
import 'package:hidi/features/posts/widgets/song_tag_card.dart';
import 'package:hidi/features/posts/widgets/song_search_bottom_sheet.dart';

/// 게시글 수정 화면 - PO-04
class PostEditView extends ConsumerStatefulWidget {
  static const String routeName = 'post-edit';
  static const String routeURL = '/posts/:postId/edit';

  final int postId;

  const PostEditView({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostEditView> createState() => _PostEditViewState();
}

class _PostEditViewState extends ConsumerState<PostEditView> {
  final _contentController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(postEditViewModelProvider(widget.postId));
    final viewModel = ref.read(postEditViewModelProvider(widget.postId).notifier);

    // 초기 데이터 로드 후 텍스트 필드에 반영
    if (!_isInitialized && state.content.isNotEmpty) {
      _contentController.text = state.content;
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _onClose(state),
          icon: const Icon(Icons.close),
        ),
        title: const Text('게시글 수정'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: state.canSubmit ? () => _onSubmit(viewModel) : null,
                    child: const Text('저장'),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 본문 입력
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 텍스트 필드
                  TextField(
                    controller: _contentController,
                    onChanged: (value) => viewModel.setContent(value),
                    maxLines: null,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: '무슨 생각을 하고 계신가요?',
                      border: InputBorder.none,
                      counterStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),

                  // 첨부된 이미지
                  if (state.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildImageGrid(state.images, viewModel),
                  ],

                  // 태그된 노래
                  if (state.taggedSong != null) ...[
                    const SizedBox(height: 16),
                    SongTagCard(
                      song: state.taggedSong!,
                      onRemove: () => viewModel.setTaggedSong(null),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 에러 메시지
          if (state.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.errorContainer,
              child: Text(
                state.error!,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),

          // 하단 툴바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // 이미지 버튼
                  IconButton(
                    onPressed: () {
                      // TODO: 이미지 선택
                    },
                    icon: const Icon(Icons.image_outlined),
                    tooltip: '이미지',
                  ),
                  // 노래 태그 버튼
                  IconButton(
                    onPressed: state.taggedSong == null
                        ? () => _onSongTagTap(viewModel)
                        : null,
                    icon: const Icon(Icons.music_note_outlined),
                    tooltip: '노래 태그',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit(PostEditViewModel viewModel) async {
    final post = await viewModel.submit();

    if (post != null && mounted) {
      // 목록에서 게시글 업데이트
      ref.read(postListViewModelProvider.notifier).updatePost(post);
      // 상세 화면 갱신을 위해 provider 무효화
      ref.invalidate(postDetailViewModelProvider(widget.postId));
      context.pop();
    }
  }

  Future<void> _onClose(PostEditorState state) async {
    // 변경사항 확인 후 닫기
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수정을 취소하시겠습니까?'),
        content: const Text('수정 중인 내용이 저장되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    if (shouldClose == true && mounted) {
      context.pop();
    }
  }

  Future<void> _onSongTagTap(PostEditViewModel viewModel) async {
    final song = await SongSearchBottomSheet.show(context);
    if (song != null) {
      viewModel.setTaggedSong(song);
    }
  }

  Widget _buildImageGrid(List<String> images, PostEditViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + (images.length < 4 ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // 추가 버튼
          if (index == images.length) {
            return InkWell(
              onTap: () {
                // TODO: 이미지 선택
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // 이미지 썸네일
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.image,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => viewModel.removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
