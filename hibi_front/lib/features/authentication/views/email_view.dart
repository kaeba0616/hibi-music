import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/viewmodels/signup_view_model.dart';
import 'package:hidi/features/authentication/views/password_view.dart';

class EmailView extends ConsumerStatefulWidget {
  const EmailView({super.key});

  @override
  ConsumerState<EmailView> createState() => _EmailViewState();
}

class _EmailViewState extends ConsumerState<EmailView> {
  late final TextEditingController _emailController = TextEditingController();

  String _email = "";
  bool _isButtonDisable = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _isEmailValid() {
    if (_email.isEmpty) return null;
    final regExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return regExp.hasMatch(_email)
        ? null
        : "Didn't match gmail form (xxxxx@xxxx.xxx)";
  }

  void _isButtonValid() {
    setState(() {
      _email = _emailController.text;
      _isButtonDisable = _email.isEmpty || _isEmailValid() != null;
    });
  }

  void _onSubmit() async {
    log("submit");
    final state = ref.read(signUpForm.notifier).state;
    ref.read(signUpForm.notifier).state = {...state, "email": _email};
    final chk = await ref.read(signUpProvider.notifier).checkEmail();
    if (chk) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PasswordView()),
      );
    }
  }

  void _onClearTap() {
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HIBI")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
        child: Column(
          children: [
            Text("Email"),
            TextField(
              controller: _emailController,
              onChanged: (value) => _isButtonValid(),
              decoration: InputDecoration(
                hintText: "email",
                errorText: _isEmailValid(),
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
