import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/viewmodels/signup_view_model.dart';
import 'package:hidi/features/authentication/views/login_view.dart';

class NicknameView extends ConsumerStatefulWidget {
  const NicknameView({super.key});

  @override
  ConsumerState<NicknameView> createState() => _NicknameViewState();
}

class _NicknameViewState extends ConsumerState<NicknameView> {
  late final TextEditingController _nicknameController =
      TextEditingController();

  String _nickname = "";
  bool _isButtonDisable = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  bool _isNicknameValid() {
    return true;
  }

  void _isButtonValid() {
    setState(() {
      _nickname = _nicknameController.text;
      _isButtonDisable = _nickname.isEmpty || !_isNicknameValid();
    });
  }

  void _onSubmit() async {
    final state = ref.read(signUpForm.notifier).state;
    ref.read(signUpForm.notifier).state = {...state, "nickname": _nickname};
    final chk = await ref.read(signUpProvider.notifier).checkNickname();
    if (chk) {
      final signUpChk = await ref.read(signUpProvider.notifier).signUp();
      if (signUpChk) {
        if (mounted) {
          context.go(LoginView.routeURL);
        }
      }
    }
  }

  void _onClearTap() {
    _nicknameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HIBI")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
        child: Column(
          children: [
            Text("Nickname"),
            TextField(
              controller: _nicknameController,
              onChanged: (value) => _isButtonValid(),
              decoration: InputDecoration(
                hintText: "nickname",
                // errorText:  ,
                suffix: GestureDetector(
                  onTap: _onClearTap,
                  child: const FaIcon(FontAwesomeIcons.circleXmark),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),

            GestureDetector(
              onTap: _isButtonDisable ? null : _onSubmit,
              child: FractionallySizedBox(
                widthFactor: 1,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.size5),
                    color:
                        _isButtonDisable
                            ? Colors.grey.shade400
                            : Colors.orange.shade300,
                  ),
                  child: AnimatedDefaultTextStyle(
                    style: TextStyle(
                      color:
                          _isButtonDisable
                              ? Colors.grey.shade300
                              : Colors.black,
                    ),
                    duration: Duration(milliseconds: 300),
                    child: Text("next", textAlign: TextAlign.center),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
