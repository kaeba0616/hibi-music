import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/authentication/viewmodels/login_view_model.dart';
import 'package:hidi/features/users/viewmodels/user_profile_view_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  void signOut(BuildContext context, WidgetRef ref, int id) async {
    await ref.read(loginProvider.notifier).signOut(context, id);
  }

  void reIssue(WidgetRef ref) async {
    await AuthenticationRepository.postReissue();
  }

  void deleteUser(BuildContext context, WidgetRef ref) async {
    await ref.read(userProfileProvider.notifier).deleteCurrentUser(context);
  }

  SliverList _buildSettinglists(BuildContext context, WidgetRef ref, int id) {
    final List<Map<String, dynamic>> settingLists = [
      {
        'title': 'SignOut',
        'subtitle': "로그아웃",
        'icon': FontAwesomeIcons.rightFromBracket,
        "onTap": () {
          signOut(context, ref, id);
        },
      },
      {
        'title': 'delete',
        'subtitle': "아이디 삭제",
        'icon': FontAwesomeIcons.userSlash,
        "onTap": () {
          deleteUser(context, ref);
        },
      },
      {
        'title': 'reIssue',
        'subtitle': "토큰 재발급",
        'icon': FontAwesomeIcons.ticket,
        "onTap": () {
          reIssue(ref);
        },
      },
    ];
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, int index) {
        final settingList = settingLists[index];
        return ListTile(
          leading: FaIcon(
            settingList['icon'],
            size: 30,
            color: Colors.greenAccent,
          ),
          title: Text(
            settingList['title'],
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            "${settingList["subtitle"]}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: settingList["onTap"],
        );
      }, childCount: settingLists.length),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("setting")),
      body: CustomScrollView(slivers: [_buildSettinglists(context, ref, 10)]),
    );
  }
}
