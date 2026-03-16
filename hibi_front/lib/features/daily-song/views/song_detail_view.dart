import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/artists/views/artist_view.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/viewmodels/daily_song_viewmodel.dart';
import 'package:hidi/features/daily-song/views/widgets/like_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// 노래 상세 화면 (DS-02)
class SongDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'songDetail';
  static const String routeURL = '/songs/:songId';

  final int songId;

  const SongDetailView({
    super.key,
    required this.songId,
  });

  @override
  ConsumerState<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends ConsumerState<SongDetailView> {
  bool _showFullLyrics = false;

  void _onArtistTap(int artistId) {
    context.pushNamed(
      ArtistView.routeName,
      pathParameters: {'artistId': artistId.toString()},
    );
  }

  void _onLikeTap() {
    ref.read(songDetailViewModelProvider(widget.songId).notifier).toggleLike();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(songDetailViewModelProvider(widget.songId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: state.isLoading
          ? _buildLoading()
          : state.hasError
              ? _buildError(state.error!)
              : state.song != null
                  ? _buildContent(state.song!, colorScheme)
                  : _buildError('노래를 찾을 수 없습니다'),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref
                    .read(songDetailViewModelProvider(widget.songId).notifier)
                    .fetchSongById(widget.songId);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DailySong song, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // AppBar with album image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          actions: [
            LikeButton(
              isLiked: song.isLiked,
              onTap: _onLikeTap,
              size: 28,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'album-${song.id}',
              child: _buildAlbumImage(song.album.imageUrl),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 곡 제목
                Text(
                  song.titleKor,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.titleJp,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // 아티스트 정보
                _buildArtistTile(song, colorScheme, textTheme),
                const Divider(height: 32),

                // 앨범 정보
                _buildAlbumInfo(song, colorScheme, textTheme),
                const Divider(height: 32),

                // 가사
                _buildLyricsSection(song, colorScheme, textTheme),

                // 외부 링크
                if (song.externalLinks.hasAnyLink) ...[
                  const Divider(height: 32),
                  _buildExternalLinks(song.externalLinks, colorScheme, textTheme),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.music_note, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildArtistTile(
    DailySong song,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          song.artist.nameKor.isNotEmpty ? song.artist.nameKor[0] : '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        song.artist.nameKor,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        song.artist.nameJp,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _onArtistTap(song.artist.id),
    );
  }

  Widget _buildAlbumInfo(
    DailySong song,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final date = song.album.releaseDate;
    final releaseDate = '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.album,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '앨범 정보',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoRow('앨범', song.album.name, textTheme, colorScheme),
        const SizedBox(height: 8),
        _buildInfoRow('발매일', releaseDate, textTheme, colorScheme),
        const SizedBox(height: 8),
        _buildInfoRow('장르', song.genre, textTheme, colorScheme),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsSection(
    DailySong song,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final hasLyrics =
        song.lyrics.japanese.isNotEmpty || song.lyrics.korean.isNotEmpty;

    if (!hasLyrics) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lyrics,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '가사',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 가사 내용
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showFullLyrics
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildFullLyrics(song.lyrics, textTheme, colorScheme),
          secondChild: _buildPreviewLyrics(song.lyrics, textTheme, colorScheme),
        ),

        const SizedBox(height: 8),

        // 전체 가사 보기/접기 버튼
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _showFullLyrics = !_showFullLyrics;
              });
            },
            icon: Icon(
              _showFullLyrics
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            label: Text(_showFullLyrics ? '가사 접기' : '전체 가사 보기'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewLyrics(
    Lyrics lyrics,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    // 첫 4줄만 표시
    final japaneseLines = lyrics.japanese.split('\n').take(4).join('\n');
    final koreanLines = lyrics.korean.split('\n').take(4).join('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (japaneseLines.isNotEmpty) ...[
          Text(
            japaneseLines,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (koreanLines.isNotEmpty)
          Text(
            koreanLines,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          '...',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFullLyrics(
    Lyrics lyrics,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    // 일본어와 한글 가사를 번갈아 표시
    final japaneseLines = lyrics.japanese.split('\n');
    final koreanLines = lyrics.korean.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < japaneseLines.length; i++) ...[
          if (japaneseLines[i].isNotEmpty)
            Text(
              japaneseLines[i],
              style: textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          if (i < koreanLines.length && koreanLines[i].isNotEmpty)
            Text(
              koreanLines[i],
              style: textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          if (japaneseLines[i].isEmpty && i < koreanLines.length && koreanLines[i].isEmpty)
            const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildExternalLinks(
    ExternalLinks links,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.link,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '외부 링크',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (links.spotify != null)
              _buildLinkChip(
                'Spotify',
                Icons.music_note,
                Colors.green,
                () => _launchUrl(links.spotify!),
              ),
            if (links.appleMusic != null)
              _buildLinkChip(
                'Apple Music',
                Icons.apple,
                Colors.pink,
                () => _launchUrl(links.appleMusic!),
              ),
            if (links.youtube != null)
              _buildLinkChip(
                'YouTube',
                Icons.play_circle_fill,
                Colors.red,
                () => _launchUrl(links.youtube!),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkChip(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
