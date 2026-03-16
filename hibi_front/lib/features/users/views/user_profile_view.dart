import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/settings/views/settings_view.dart';
import 'package:hidi/features/users/viewmodels/user_profile_view_model.dart';
import 'package:hidi/features/users/views/user_profile_edit_view.dart';

class MyPageView extends ConsumerStatefulWidget {
  const MyPageView({super.key});

  @override
  ConsumerState<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends ConsumerState<MyPageView> {
  final String userName = 'Hidi';
  final int followers = 1337;
  final int following = 42;
  final String profileImageUrl = ''; // Intentionally left blank for placeholder

  final List<Map<String, dynamic>> playlists = [
    {'name': 'Liked Songs', 'count': 128, 'icon': Icons.favorite},
  ];
  final ScrollController _scrollController = ScrollController();

  double _appBarOpacity = 0.0;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final maxScroll = 200.0; // The scroll distance to reach full opacity
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

  void _OnEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileEditView()),
    );
  }

  void _OnSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsView()),
    );
  }

  void deleteUser() async {
    await ref.read(userProfileProvider.notifier).deleteCurrentUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildUserInfo(),
                _buildSectionHeader('Public Playlists'),
                _buildPlaylists(),
                SliverFillRemaining(),
              ],
            ),
          ),
          _buildAppBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal.shade300.withValues(alpha: _appBarOpacity),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _OnSettings,
          ),
        ],

        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white.withValues(alpha: _appBarOpacity),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildUserInfo() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.white],
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
                    backgroundColor: Colors.teal,
                    child: Text(
                      userName.substring(0, 1),
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildStatColumn('Followers', followers),
                      _buildStatColumn('Following', following),
                      OutlinedButton(
                        onPressed: _OnEditProfile,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ),
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

  SliverList _buildPlaylists() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        final playlist = playlists[index];
        return ListTile(
          leading: Icon(playlist['icon'], size: 30, color: Colors.greenAccent),
          title: Text(
            playlist['name'],
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            '${playlist['count']} songs',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      }, childCount: playlists.length),
    );
  }
}


            // SliverToBoxAdapter(
            //   child: TextButton(
            //     child: Text("SignOut"),
            //     onPressed: () => signOut(10),
            //   ),
            // ),
            // SliverToBoxAdapter(
            //   child: TextButton(
            //     child: Text("ReIssue"),
            //     onPressed: () => reIssue(),
            //   ),
            // ),
            // SliverToBoxAdapter(
            //   child: Column(
            //     children: [
            //       userState.when(
            //         data: (user) {
            //           return Column(
            //             children: [
            //               Text("${user.id}"),
            //               Text("${user.email}"),
            //               Text("${user.nickname}"),
            //             ],
            //           );
            //         },
            //         error:
            //             (error, stackTrace) =>
            //                 Center(child: Text("Error: $error")),
            //         loading:
            //             () =>
            //                 Center(child: CircularProgressIndicator.adaptive()),
            //       ),
            //     ],
            //   ),
            // ),
            // SliverToBoxAdapter(
            //   child: TextButton(onPressed: deleteUser, child: Text("delete")),
            // ),
            // SliverToBoxAdapter(
            //   child: Column(
            //     children: [
            //       TextField(
            //         controller: _nicknameController,
            //         onChanged: (value) {
            //           formData['nickname'] = value;
            //         },
            //         decoration: InputDecoration(
            //           hintText: "nickname",
            //           // errorText:  ,
            //           suffix: GestureDetector(
            //             onTap: () => _onClearTap(_nicknameController),
            //             child: const FaIcon(FontAwesomeIcons.circleXmark),
            //           ),
            //           enabledBorder: UnderlineInputBorder(
            //             borderSide: BorderSide(color: Colors.grey.shade400),
            //           ),
            //         ),
            //       ),
            //       TextField(
            //         controller: _passwordController,
            //         onChanged: (value) {
            //           formData['password'] = value;
            //         },
            //         decoration: InputDecoration(
            //           hintText: "password",
            //           // errorText:  ,
            //           suffix: GestureDetector(
            //             onTap: () => _onClearTap(_passwordController),
            //             child: const FaIcon(FontAwesomeIcons.circleXmark),
            //           ),
            //           enabledBorder: UnderlineInputBorder(
            //             borderSide: BorderSide(color: Colors.grey.shade400),
            //           ),
            //         ),
            //       ),
            //       GestureDetector(
            //         onTap: _onSubmit,
            //         child: FractionallySizedBox(
            //           widthFactor: 1,
            //           child: AnimatedContainer(
            //             duration: Duration(milliseconds: 300),
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(Sizes.size5),
            //               color: Colors.orange.shade300,
            //             ),
            //             child: AnimatedDefaultTextStyle(
            //               style: TextStyle(color: Colors.black),
            //               duration: Duration(milliseconds: 300),
            //               child: Text("edit", textAlign: TextAlign.center),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),