// ignore_for_file: use_build_context_synchronously

import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late final DatabaseService _databaseService;
  late final AuthService _authService;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _databaseService = GetIt.instance<DatabaseService>();
    _authService = GetIt.instance<AuthService>();
    _notificationService = GetIt.instance<NotificationService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final success = await _authService.logout();
              if (success) {
                if (!mounted) return;
                _notificationService.showNotification(
                  context,
                  message: "Logged out successfully",
                  icon: Icons.check,
                );
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Center(child: _chatList()),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          if (users.isEmpty) {
            return const Center(child: Text("No users found"));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChatTile(
                  userProfile: user,
                  onTap: () async {
                    final chatExists = await _databaseService.checkChatExists(
                      _authService.user!.uid,
                      user.uid!,
                    );
                    if (!chatExists) {
                      await _databaseService.createChat(
                        _authService.user!.uid,
                        user.uid!,
                      );
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChatPage(chatUser: user);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          return const Center(child: Text("No users found"));
        }
      },
    );
  }
}
