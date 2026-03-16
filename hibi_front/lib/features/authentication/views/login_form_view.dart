import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/viewmodels/login_view_model.dart';

class LoginFormView extends ConsumerStatefulWidget {
  const LoginFormView({super.key});

  @override
  ConsumerState<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends ConsumerState<LoginFormView> {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  bool _isButtonDisable = false;
  bool _isObscure = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onClearTap(TextEditingController controller) {
    controller.clear();
  }

  void _toggleObscrueText() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _isButtonValid() {
    setState(() {});
  }

  void _onSubmit() async {
    final state = ref.read(loginForm.notifier).state;
    ref.read(loginForm.notifier).state = {
      ...state,
      "email": formData["email"],
      "password": formData["password"],
    };
    await ref.read(loginProvider.notifier).signin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HIBI")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("LoginForm"),

              TextField(
                controller: _emailController,
                onChanged: (value) {
                  formData['email'] = value;
                  _isButtonValid();
                },
                decoration: InputDecoration(
                  hintText: "Email",
                  // errorText:  ,
                  suffix: GestureDetector(
                    onTap: () => _onClearTap(_emailController),
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
                  formData["password"] = value;
                  _isButtonValid();
                },
                decoration: InputDecoration(
                  hintText: "password",
                  // errorText:  ,
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _onClearTap(_passwordController),
                        child: const FaIcon(FontAwesomeIcons.circleXmark),
                      ),

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
      ),
    );
  }
}
