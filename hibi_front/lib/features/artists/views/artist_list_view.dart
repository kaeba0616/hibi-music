import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/artists/viewmodels/artist_list_view_model.dart';
import 'package:hidi/features/artists/views/widgets/artist_card.dart';
import 'package:hidi/features/artists/views/widgets/artist_empty_view.dart';
import 'package:hidi/features/artists/views/widgets/artist_error_view.dart';
import 'package:hidi/features/artists/views/widgets/artist_loading_view.dart';

/// 아티스트 목록 화면 (AR-01)
class ArtistListView extends ConsumerStatefulWidget {
  const ArtistListView({super.key});

  @override
  ConsumerState<ArtistListView> createState() => _ArtistListViewState();
}

class _ArtistListViewState extends ConsumerState<ArtistListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filterType = _tabController.index == 0
          ? ArtistFilterType.all
          : ArtistFilterType.following;
      ref.read(artistListProvider.notifier).setFilter(filterType);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(artistListProvider.notifier).setSearchQuery(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(artistListProvider.notifier).setSearchQuery('');
  }

  void _navigateToDetail(int artistId) {
    context.push('/artists/$artistId');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(artistListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('아티스트'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 검색 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: '아티스트 검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              // 필터 탭
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '전체'),
                  Tab(text: '팔로우 중'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(artistListProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(ArtistListState state) {
    // 로딩 상태
    if (state.isLoading && state.artists.isEmpty) {
      return const ArtistListLoadingView();
    }

    // 에러 상태
    if (state.error != null && state.artists.isEmpty) {
      return ArtistErrorView(
        message: state.error!,
        onRetry: () => ref.read(artistListProvider.notifier).refresh(),
      );
    }

    final filteredArtists = state.filteredArtists;

    // Empty 상태
    if (filteredArtists.isEmpty) {
      return ArtistEmptyView(
        isFollowingFilter: state.filterType == ArtistFilterType.following,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );
    }

    // 아티스트 그리드
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredArtists.length,
      itemBuilder: (context, index) {
        final artist = filteredArtists[index];
        return ArtistCard(
          artist: artist,
          onTap: () => _navigateToDetail(artist.id),
        );
      },
    );
  }
}
