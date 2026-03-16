import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/viewmodels/post_viewmodel.dart';
import 'package:hidi/features/posts/widgets/song_tag_card.dart';

/// 노래 선택 바텀시트 (PO-05)
class SongSearchBottomSheet extends ConsumerStatefulWidget {
  final Function(TaggedSong) onSongSelected;

  const SongSearchBottomSheet({
    super.key,
    required this.onSongSelected,
  });

  @override
  ConsumerState<SongSearchBottomSheet> createState() =>
      _SongSearchBottomSheetState();

  /// 바텀시트 표시 헬퍼
  static Future<TaggedSong?> show(BuildContext context) {
    return showModalBottomSheet<TaggedSong>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SongSearchBottomSheet(
          onSongSelected: (song) => Navigator.of(context).pop(song),
        ),
      ),
    );
  }
}

class _SongSearchBottomSheetState extends ConsumerState<SongSearchBottomSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // 초기 검색 (전체 목록)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(songSearchViewModelProvider.notifier).search('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(songSearchViewModelProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(songSearchViewModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '노래 태그',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // 검색 입력
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '노래 또는 아티스트 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          // 검색 결과
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SongSearchState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.query.isEmpty
                  ? '노래를 검색해주세요'
                  : '"${state.query}"에 대한 결과가 없습니다',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, index) {
        final song = state.results[index];
        return SongSearchItem(
          song: song,
          onTap: () => widget.onSongSelected(song),
        );
      },
    );
  }
}
