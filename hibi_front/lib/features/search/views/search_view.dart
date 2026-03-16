import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/search/models/search_models.dart';
import 'package:hidi/features/search/viewmodels/search_viewmodel.dart';
import 'package:hidi/features/search/widgets/artist_search_tile.dart';
import 'package:hidi/features/search/widgets/post_search_tile.dart';
import 'package:hidi/features/search/widgets/recent_search_item.dart';
import 'package:hidi/features/search/widgets/search_bar_widget.dart';
import 'package:hidi/features/search/widgets/search_category_tabs.dart';
import 'package:hidi/features/search/widgets/search_empty_view.dart';
import 'package:hidi/features/search/widgets/search_section_header.dart';
import 'package:hidi/features/search/widgets/song_search_tile.dart';
import 'package:hidi/features/search/widgets/user_search_tile.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
    final viewModel = ref.read(searchViewModelProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 검색창
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                controller: _searchController,
                autofocus: false,
                onChanged: (query) {
                  viewModel.onQueryChanged(query);
                },
                onSubmitted: (query) {
                  if (query.length >= 2) {
                    viewModel.search(query);
                  }
                },
                onClear: () {
                  viewModel.clearQuery();
                },
              ),
            ),

            // 검색 결과가 있으면 카테고리 탭 표시
            if (state.hasResult) ...[
              SearchCategoryTabs(
                selectedCategory: state.selectedCategory,
                onCategoryChanged: (category) {
                  viewModel.selectCategory(category);
                },
                result: state.result,
              ),
              const Divider(height: 1),
            ],

            // 본문
            Expanded(
              child: _buildContent(state, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state, SearchViewModel viewModel) {
    // 로딩 중
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러
    if (state.error != null) {
      return SearchErrorView(
        message: state.error!,
        onRetry: () => viewModel.retry(),
      );
    }

    // 검색 결과가 있는 경우
    if (state.hasResult) {
      if (state.isEmpty) {
        return SearchEmptyView(
          query: state.query,
          category: state.selectedCategory,
          suggestedKeywords: state.popularKeywords,
          onKeywordTap: (keyword) {
            _searchController.text = keyword;
            viewModel.search(keyword);
          },
        );
      }

      return _buildSearchResults(state, viewModel);
    }

    // 초기 상태 (검색 전)
    return _buildInitialContent(state, viewModel);
  }

  Widget _buildInitialContent(SearchState state, SearchViewModel viewModel) {
    if (state.recentSearches.isEmpty) {
      return const RecentSearchEmptyView();
    }

    return ListView(
      children: [
        // 최근 검색어 헤더
        RecentSearchHeader(
          onClearAll: () => viewModel.clearAllRecentSearches(),
        ),

        // 최근 검색어 목록
        ...state.recentSearches.map((recent) {
          return RecentSearchItem(
            recentSearch: recent,
            onTap: () {
              _searchController.text = recent.query;
              viewModel.search(recent.query);
            },
            onDelete: () => viewModel.deleteRecentSearch(recent.query),
          );
        }),

        // 인기 검색어 (선택적)
        if (state.popularKeywords.isNotEmpty) ...[
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '인기 검색어',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.popularKeywords.map((keyword) {
                return ActionChip(
                  label: Text('#$keyword'),
                  onPressed: () {
                    _searchController.text = keyword;
                    viewModel.search(keyword);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchResults(SearchState state, SearchViewModel viewModel) {
    final result = state.result!;
    final category = state.selectedCategory;

    // 특정 카테고리만 표시
    if (category != SearchCategory.all) {
      return _buildCategoryResults(state, viewModel, category);
    }

    // 전체 결과 (각 카테고리 미리보기)
    return ListView(
      children: [
        // 노래 결과
        if (result.songs.isNotEmpty) ...[
          SearchSectionHeader(
            title: '노래',
            count: result.totalSongs,
            onMoreTap: () {
              viewModel.selectCategory(SearchCategory.songs);
            },
          ),
          ...result.songs.take(3).map((song) {
            return SongSearchTile(
              song: song,
              onTap: () => _navigateToSong(song.id),
            );
          }),
          const SizedBox(height: 8),
        ],

        // 아티스트 결과
        if (result.artists.isNotEmpty) ...[
          SearchSectionHeader(
            title: '아티스트',
            count: result.totalArtists,
            onMoreTap: () {
              viewModel.selectCategory(SearchCategory.artists);
            },
          ),
          ...result.artists.take(3).map((artist) {
            return ArtistSearchTile(
              artist: artist,
              onTap: () => _navigateToArtist(artist.id),
              onFollowTap: () => viewModel.toggleArtistFollow(artist.id),
            );
          }),
          const SizedBox(height: 8),
        ],

        // 게시글 결과
        if (result.posts.isNotEmpty) ...[
          SearchSectionHeader(
            title: '게시글',
            count: result.totalPosts,
            onMoreTap: () {
              viewModel.selectCategory(SearchCategory.posts);
            },
          ),
          ...result.posts.take(3).map((post) {
            return PostSearchTile(
              post: post,
              onTap: () => _navigateToPost(post.id),
            );
          }),
          const SizedBox(height: 8),
        ],

        // 사용자 결과
        if (result.users.isNotEmpty) ...[
          SearchSectionHeader(
            title: '사용자',
            count: result.totalUsers,
            onMoreTap: () {
              viewModel.selectCategory(SearchCategory.users);
            },
          ),
          ...result.users.take(3).map((user) {
            return UserSearchTile(
              user: user,
              onTap: () => _navigateToUser(user.id),
              onFollowTap: () => viewModel.toggleUserFollow(user.id),
            );
          }),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryResults(
    SearchState state,
    SearchViewModel viewModel,
    SearchCategory category,
  ) {
    final result = state.result!;

    switch (category) {
      case SearchCategory.songs:
        if (result.songs.isEmpty) {
          return SearchEmptyView(
            query: state.query,
            category: category,
            suggestedKeywords: state.popularKeywords,
          );
        }
        return ListView.builder(
          itemCount: result.songs.length,
          itemBuilder: (context, index) {
            final song = result.songs[index];
            return SongSearchTile(
              song: song,
              showDetails: true,
              onTap: () => _navigateToSong(song.id),
            );
          },
        );

      case SearchCategory.artists:
        if (result.artists.isEmpty) {
          return SearchEmptyView(
            query: state.query,
            category: category,
            suggestedKeywords: state.popularKeywords,
          );
        }
        return ListView.builder(
          itemCount: result.artists.length,
          itemBuilder: (context, index) {
            final artist = result.artists[index];
            return ArtistSearchTile(
              artist: artist,
              onTap: () => _navigateToArtist(artist.id),
              onFollowTap: () => viewModel.toggleArtistFollow(artist.id),
            );
          },
        );

      case SearchCategory.posts:
        if (result.posts.isEmpty) {
          return SearchEmptyView(
            query: state.query,
            category: category,
            suggestedKeywords: state.popularKeywords,
          );
        }
        return ListView.builder(
          itemCount: result.posts.length,
          itemBuilder: (context, index) {
            final post = result.posts[index];
            return PostSearchTile(
              post: post,
              onTap: () => _navigateToPost(post.id),
            );
          },
        );

      case SearchCategory.users:
        if (result.users.isEmpty) {
          return SearchEmptyView(
            query: state.query,
            category: category,
            suggestedKeywords: state.popularKeywords,
          );
        }
        return ListView.builder(
          itemCount: result.users.length,
          itemBuilder: (context, index) {
            final user = result.users[index];
            return UserSearchTile(
              user: user,
              onTap: () => _navigateToUser(user.id),
              onFollowTap: () => viewModel.toggleUserFollow(user.id),
            );
          },
        );

      case SearchCategory.all:
        // 위에서 이미 처리됨
        return const SizedBox.shrink();
    }
  }

  void _navigateToSong(int songId) {
    context.push('/songs/$songId');
  }

  void _navigateToArtist(int artistId) {
    context.push('/artists/$artistId');
  }

  void _navigateToPost(int postId) {
    context.push('/posts/$postId');
  }

  void _navigateToUser(int userId) {
    context.push('/users/$userId');
  }
}
