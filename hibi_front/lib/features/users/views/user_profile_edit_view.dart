import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidi/features/users/viewmodels/user_profile_view_model.dart';

class UserProfileEditView extends ConsumerStatefulWidget {
  const UserProfileEditView({super.key});

  @override
  ConsumerState<UserProfileEditView> createState() =>
      _UserProfileEditViewState();
}

class _UserProfileEditViewState extends ConsumerState<UserProfileEditView> {
  final String userName = 'Hidi';
  final int followers = 1337;
  final int following = 42;
  final String profileImageUrl = ''; // Intentionally left blank for placeholder

  late final TextEditingController _nicknameController =
      TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  Map<String, dynamic> formData = {};

  bool _isObscure = true;
  void _toggleObscrueText() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _onClearTap(TextEditingController controller) {
    controller.clear();
  }

  void _onSubmit() async {
    await ref
        .read(userProfileProvider.notifier)
        .patchCurrentUser(context, formData["nickname"], formData["password"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("edit profile"),
        actions: [TextButton(onPressed: _onSubmit, child: Text("save"))],
      ),

      body: CustomScrollView(slivers: [_buildUserInfo(), _buildEditProfile()]),
    );
  }

  SliverToBoxAdapter _buildUserInfo() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Center(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEditProfile() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              onChanged: (value) {
                formData['nickname'] = value;
              },
              decoration: InputDecoration(
                hintText: "nickname",
                // errorText:  ,
                suffix: GestureDetector(
                  onTap: () => _onClearTap(_nicknameController),
                  child: const FaIcon(FontAwesomeIcons.circleXmark),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              onChanged: (value) {
                formData['password'] = value;
              },
              decoration: InputDecoration(
                hintText: "password",
                // errorText:  ,
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleObscrueText(),
                      child:
                          _isObscure
                              ? FaIcon(FontAwesomeIcons.eye)
                              : FaIcon(FontAwesomeIcons.eyeSlash),
                    ),
                  ],
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
