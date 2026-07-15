import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/daily-song/views/liked_songs_view.dart';
import 'package:hidi/features/settings/views/settings_view.dart';
import 'package:hidi/features/users/viewmodels/user_profile_view_model.dart';
import 'package:hidi/features/users/views/my_comments_view.dart';
import 'package:hidi/features/users/views/user_profile_edit_view.dart';

class MyPageView extends ConsumerStatefulWidget {
  const MyPageView({super.key});

  @override
  ConsumerState<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends ConsumerState<MyPageView> {
  final ScrollController _scrollController = ScrollController();

  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      const maxScroll = 200.0; // The scroll distance to reach full opacity
      final offset = _scrollController.offset;
      final newOpacity = (offset / maxScroll).clamp(0.0, 1.0);
      if (newOpacity != _appBarOpacity) {
        setState(() {
          _appBarOpacity = newOpacity;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileEditView()),
    );
  }

  void _onSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;
    final stats = ref.watch(myProfileStatsProvider).value;
    final nickname = user?.nickname ?? '';

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildUserInfo(
                  nickname: nickname,
                  followers: stats?.followerCount ?? 0,
                  following: stats?.followingCount ?? 0,
                ),
                _buildSectionHeader('My Activity'),
                _buildMyActivities(),
                _buildSectionHeader('Public Playlists'),
                _buildPlaylists(),
                const SliverFillRemaining(),
              ],
            ),
          ),
          _buildAppBar(nickname),
        ],
      ),
    );
  }

  Widget _buildAppBar(String nickname) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary.withValues(alpha: _appBarOpacity),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _onSettings,
          ),
        ],
        title: Text(
          nickname,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onPrimary.withValues(alpha: _appBarOpacity),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildUserInfo({
    required String nickname,
    required int followers,
    required int following,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = nickname.isNotEmpty ? nickname.substring(0, 1) : '?';

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primaryContainer, colorScheme.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 40,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nickname,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildStatColumn('Followers', followers),
                      _buildStatColumn('Following', following),
                      OutlinedButton(
                        onPressed: _onEditProfile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(color: colorScheme.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int number) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(number.toString(), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4.0),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMyActivities() {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: ListTile(
        leading: Icon(
          Icons.chat_bubble_outline,
          size: 30,
          color: colorScheme.primary,
        ),
        title: Text(
          '내가 쓴 댓글',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyCommentsView()),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildPlaylists() {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: ListTile(
        leading: Icon(Icons.favorite, size: 30, color: colorScheme.primary),
        title: Text(
          'Liked Songs',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(LikedSongsView.routeURL),
      ),
    );
  }
}
