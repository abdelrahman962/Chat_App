import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/validator/input_validate.dart';
import 'package:flutter/material.dart';
import '../widgets/form_field.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  late final AuthService _authService;
  late final NotificationService _notificationService;

  String? _email;
  String? _password;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance<AuthService>();
    _notificationService = GetIt.instance<NotificationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, body: _buildUI());
  }

  Widget _buildUI() {
    final width = MediaQuery.sizeOf(context).width;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(children: [_header(width), _loginForm(), _signup()]),
      ),
    );
  }

  Widget _header(double width) {
    return SizedBox(
      width: width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Login",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    final height = MediaQuery.sizeOf(context).height;
    return Container(
      height: height * 0.4,
      margin: EdgeInsets.symmetric(vertical: height * 0.09),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomField(
              hintText: "Email",
              height: height * 0.1,
              validation: emailValidationRegex,
              onSaved: (value) => _email = value,
            ),
            CustomField(
              hintText: "Password",
              height: height * 0.1,
              validation: passwordValidationRegex,
              obscureText: true,
              onSaved: (value) => _password = value,
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();

            final success = await _authService.login(_email!, _password!);
            if (success && mounted) {
              Navigator.pushReplacementNamed(context, "/home");
            }
          } else {
            _notificationService.showNotification(
              context,
              message: "Please fix the errors in red",
              icon: Icons.error,
            );
          }
        },
        color: Colors.blue,
        child: const Text("Login", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _signup() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Don't have an account? "),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, "/signup");
            },
            child: const Text(
              "Sign up",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
