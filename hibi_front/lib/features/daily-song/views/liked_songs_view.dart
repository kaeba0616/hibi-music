import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/viewmodels/liked_songs_viewmodel.dart';
import 'package:hidi/features/daily-song/views/song_detail_view.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';

/// RS-01: 좋아요 곡 모아보기 화면 (F15)
class LikedSongsView extends ConsumerStatefulWidget {
  static const String routeName = 'likedSongs';
  static const String routeURL = '/liked-songs';

  const LikedSongsView({super.key});

  @override
  ConsumerState<LikedSongsView> createState() => _LikedSongsViewState();
}

class _LikedSongsViewState extends ConsumerState<LikedSongsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(likedSongsViewModelProvider.notifier).loadLikedSongs();
    });
  }

  void _onSongTap(int songId) {
    context.pushNamed(
      SongDetailView.routeName,
      pathParameters: {'songId': songId.toString()},
    );
  }

  void _onRemoveLike(int songId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('좋아요 취소'),
        content: const Text('이 곡의 좋아요를 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(likedSongsViewModelProvider.notifier).removeLike(songId);
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(likedSongsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('좋아요 곡'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildError(state.error!)
              : state.songs.isEmpty
                  ? _buildEmpty(colorScheme, textTheme)
                  : _buildList(state.songs, colorScheme, textTheme),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref.read(likedSongsViewModelProvider.notifier).loadLikedSongs();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 좋아요한 곡이 없어요',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '오늘의 곡에서 마음에 드는\n노래에 좋아요를 눌러보세요!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                context.go('/${MainNavigationView.initialTab}');
              },
              child: const Text('오늘의 곡 보러가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List<DailySong> songs,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '총 ${songs.length}곡',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final song = songs[index];
              return _buildLikedSongTile(song, colorScheme, textTheme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLikedSongTile(
    DailySong song,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final date = song.recommendedDate;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 48,
          height: 48,
          child: _buildAlbumImage(song.album.imageUrl),
        ),
      ),
      title: Text(
        song.titleKor,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              song.artist.nameKor,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            dateStr,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
        onPressed: () => _onRemoveLike(song.id),
      ),
      onTap: () => _onSongTap(song.id),
    );
  }

  Widget _buildAlbumImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.music_note, size: 24, color: Colors.grey),
    );
  }
}
