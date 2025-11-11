import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/validator/input_validate.dart';
import 'package:chat_app/widgets/form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _signupFormKey = GlobalKey<FormState>();
  late final AuthService _authService;
  late final DatabaseService _databaseService;
  late final NotificationService _notificationService;

  String? _email;
  String? _password;
  String? _name;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance<AuthService>();
    _databaseService = GetIt.instance<DatabaseService>();
    _notificationService = GetIt.instance<NotificationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false, body: _buildUI());
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
            "Signup",
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

  Widget? _buildUI() {
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),

        child: Column(
          children: [
            _header(width),
            if (!_isLoading) _signupForm(),
            if (!_isLoading) _login(),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _signupForm() {
    final height = MediaQuery.sizeOf(context).height;
    return Container(
      height: height * 0.4,
      margin: EdgeInsets.symmetric(vertical: height * 0.09),
      child: Form(
        key: _signupFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomField(
              hintText: "name",
              height: 60,
              validation: nameValidationRegex,
              onSaved: (value) => _name = value,
            ),
            CustomField(
              hintText: "Email",
              height: 60,
              validation: emailValidationRegex,
              onSaved: (value) => _email = value,
            ),
            CustomField(
              hintText: "Password",
              height: 60,
              obscureText: true,
              validation: passwordValidationRegex,
              onSaved: (value) => _password = value,
            ),

            _signupButton(),
          ],
        ),
      ),
    );
  }

  Widget _signupButton() {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });
          try {
            if (_signupFormKey.currentState?.validate() ?? false) {
              _signupFormKey.currentState?.save();
              final success = await _authService.signup(_email!, _password!);
              if (success) {
                await _databaseService.createUserProfile(
                  UserProfile(uid: _authService.user!.uid, name: _name),
                );
                if (!mounted) return;
                _notificationService.showNotification(
                  context,
                  message: "Signup successful",
                  icon: Icons.check,
                );
                Navigator.pushReplacementNamed(context, "/home");
              }
            } else {
              throw Exception("Unable to upload signup user");
            }
          } catch (e) {
            _notificationService.showNotification(
              // ignore: use_build_context_synchronously
              context,
              message: "Signup failed. Please try again.",
              icon: Icons.error,
            );
          }
          setState(() {
            _isLoading = false;
          });
        },
        color: Colors.blue,
        child: const Text('Sign up', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _login() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
