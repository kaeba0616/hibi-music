import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/viewmodels/signup_view_model.dart';
import 'package:hidi/features/authentication/views/nickname_view.dart';

class PasswordView extends ConsumerStatefulWidget {
  const PasswordView({super.key});

  @override
  ConsumerState<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends ConsumerState<PasswordView> {
  late final TextEditingController _passwordController1 =
      TextEditingController();
  late final TextEditingController _passwordController2 =
      TextEditingController();

  String _password1 = "";
  String _password2 = "";
  bool _isButtonDisable = true;
  bool _isObscure1 = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController1.dispose();
    super.dispose();
  }

  String? _isPasswordValid() {
    List<String> errors = [];

    if (_password1.isEmpty) return null;

    if (_password1.length < 8) {
      errors.add("최소 8글자 이상");
    }

    return errors.isEmpty ? null : errors.join('\n');
  }

  void _toggleObscrueText() {
    setState(() {
      _isObscure1 = !_isObscure1;
    });
  }

  void _onClearTap(TextEditingController controller) {
    controller.clear();
  }

  bool _isSamePassword() {
    return _password1 == _password2;
  }

  void _isButtonValid() {
    setState(() {
      _isButtonDisable =
          _password1.isEmpty ||
          _isPasswordValid() != null ||
          !_isSamePassword();
    });
  }

  void _onSubmit() {
    final state = ref.read(signUpForm.notifier).state;
    ref.read(signUpForm.notifier).state = {...state, "password": _password1};
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NicknameView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HIBI")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
        child: Column(
          children: [
            Text("password"),
            TextField(
              controller: _passwordController1,
              obscureText: _isObscure1,
              onChanged: (value) {
                setState(() {
                  _password1 = value;
                });
                _isButtonValid();
              },
              decoration: InputDecoration(
                hintText: "password",
                errorText: _isPasswordValid(),
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _onClearTap(_passwordController1),
                      child: const FaIcon(FontAwesomeIcons.circleXmark),
                    ),
                    GestureDetector(
                      onTap: _toggleObscrueText,
                      child:
                          _isObscure1
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

            TextField(
              controller: _passwordController2,
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password2 = value;
                });
                _isButtonValid();
              },
              decoration: InputDecoration(
                hintText: "repassword",

                errorText:
                    _isSamePassword() || _password2 == ""
                        ? ""
                        : "it is not correct each other.",
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _onClearTap(_passwordController2),
                      child: const FaIcon(FontAwesomeIcons.circleXmark),
                    ),
                  ],
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
