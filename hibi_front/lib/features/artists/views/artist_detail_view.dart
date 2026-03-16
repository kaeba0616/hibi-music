import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/artists/viewmodels/artist_detail_view_model.dart';
import 'package:hidi/features/artists/views/widgets/artist_error_view.dart';
import 'package:hidi/features/artists/views/widgets/artist_loading_view.dart';
import 'package:hidi/features/artists/views/widgets/follow_button.dart';
import 'package:hidi/features/artists/views/widgets/song_list_tile.dart';

/// 아티스트 상세 화면 (AR-02)
class ArtistDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'artistDetail';
  static const String routeURL = '/artists/:artistId';

  final int artistId;

  const ArtistDetailView({
    super.key,
    required this.artistId,
  });

  @override
  ConsumerState<ArtistDetailView> createState() => _ArtistDetailViewState();
}

class _ArtistDetailViewState extends ConsumerState<ArtistDetailView> {
  bool _isDescriptionExpanded = false;

  void _toggleFollow() {
    ref.read(artistDetailProvider(widget.artistId).notifier).toggleFollow();
  }

  void _navigateToSongDetail(int songId) {
    context.push('/songs/$songId');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(artistDetailProvider(widget.artistId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (state.detail != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FollowButton(
                isFollowing: state.detail!.artist.isFollowing,
                onTap: _toggleFollow,
              ),
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(ArtistDetailState state, ThemeData theme) {
    // 로딩 상태
    if (state.isLoading) {
      return const ArtistDetailLoadingView();
    }

    // 에러 상태
    if (state.error != null) {
      return ArtistErrorView(
        message: state.error!,
        onRetry: () => ref
            .read(artistDetailProvider(widget.artistId).notifier)
            .refresh(widget.artistId),
      );
    }

    final detail = state.detail;
    if (detail == null) {
      return const ArtistErrorView(message: '아티스트를 찾을 수 없습니다');
    }

    final artist = detail.artist;
    final songs = detail.songs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 이미지
          Hero(
            tag: 'artist_${artist.id}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: artist.profileImage != null
                  ? NetworkImage(artist.profileImage!)
                  : null,
              child: artist.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // 아티스트 이름 (한글)
          Text(
            artist.nameKor,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // 아티스트 이름 (영문)
          Text(
            artist.nameEng,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 통계 섹션
          _buildStatsSection(theme, artist.followerCount, artist.songCount),
          const SizedBox(height: 24),

          // 소개 섹션
          if (artist.description != null && artist.description!.isNotEmpty)
            _buildDescriptionSection(theme, artist.description!),

          const SizedBox(height: 24),

          // 노래 목록 섹션
          _buildSongsSection(theme, songs),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, int followerCount, int songCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(theme, '팔로워', _formatNumber(followerCount)),
          Container(
            height: 24,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          _buildStatItem(theme, '노래', '$songCount곡'),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, String description) {
    final isLong = description.length > 100;
    final displayText = _isDescriptionExpanded || !isLong
        ? description
        : '${description.substring(0, 100)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '소개',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          displayText,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isLong)
          TextButton(
            onPressed: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(_isDescriptionExpanded ? '접기' : '더 보기'),
          ),
      ],
    );
  }

  Widget _buildSongsSection(ThemeData theme, List songs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.music_note,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '노래 목록',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (songs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '아직 등록된 노래가 없습니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongListTile(
                song: song,
                onTap: () => _navigateToSongDetail(song.id),
              );
            },
          ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }
}
