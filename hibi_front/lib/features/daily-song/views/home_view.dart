import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/artists/views/artist_view.dart';
import 'package:hidi/features/daily-song/viewmodels/daily_song_viewmodel.dart';
import 'package:hidi/features/daily-song/views/song_detail_view.dart';
import 'package:hidi/features/daily-song/views/widgets/empty_song_view.dart';
import 'package:hidi/features/daily-song/views/widgets/error_song_view.dart';
import 'package:hidi/features/daily-song/views/widgets/loading_song_view.dart';
import 'package:hidi/features/daily-song/views/widgets/song_card.dart';

/// 홈 화면 - 오늘의 노래 표시 (DS-01)
class HomeView extends ConsumerStatefulWidget {
  static const String routeName = 'home';
  static const String routeURL = '/home';

  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 오늘의 노래 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailySongViewModelProvider.notifier).fetchTodaySong();
    });
  }

  void _onSongTap(int songId) {
    context.pushNamed(
      SongDetailView.routeName,
      pathParameters: {'songId': songId.toString()},
    );
  }

  void _onArtistTap(int artistId) {
    context.pushNamed(
      ArtistView.routeName,
      pathParameters: {'artistId': artistId.toString()},
    );
  }

  void _onLikeTap() {
    ref.read(dailySongViewModelProvider.notifier).toggleLike();
  }

  Future<void> _onRefresh() async {
    await ref.read(dailySongViewModelProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailySongViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'hibi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 프로필 화면으로 이동
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 오늘 날짜 표시
                _buildDateHeader(context, textTheme, colorScheme),
                const SizedBox(height: 24),

                // 노래 카드 또는 상태 표시
                _buildContent(state),

                const SizedBox(height: 16),

                // 힌트 텍스트 (노래가 있을 때만)
                if (state.hasData)
                  Text(
                    '탭해서 자세히 보기',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    final now = DateTime.now();
    final koreanDate = '${now.year}년 ${now.month}월 ${now.day}일';
    final japaneseDay = _getJapaneseDayOfWeek(now.weekday);
    final koreanDay = _getKoreanDayOfWeek(now.weekday);

    return Column(
      children: [
        Text(
          koreanDate,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$japaneseDay ($koreanDay)',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(DailySongState state) {
    if (state.isLoading) {
      return const LoadingSongView();
    }

    if (state.hasError) {
      return ErrorSongView(
        message: state.error!,
        onRetry: _onRefresh,
      );
    }

    if (state.isEmpty || state.song == null) {
      return EmptySongView(
        onRefresh: _onRefresh,
      );
    }

    final song = state.song!;
    return SongCard(
      song: song,
      onTap: () => _onSongTap(song.id),
      onLikeTap: _onLikeTap,
      onArtistTap: () => _onArtistTap(song.artist.id),
    );
  }

  String _getJapaneseDayOfWeek(int weekday) {
    const days = ['月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日', '日曜日'];
    return days[weekday - 1];
  }

  String _getKoreanDayOfWeek(int weekday) {
    const days = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return days[weekday - 1];
  }
}
