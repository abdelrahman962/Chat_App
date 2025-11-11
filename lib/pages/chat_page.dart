import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final AuthService _authService;
  late final DatabaseService _databaseService;
  late final ChatUser _currentUser;
  late final ChatUser _otherUser;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance<AuthService>();
    _databaseService = GetIt.instance<DatabaseService>();
    _currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    _otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 10),
            Text(
              widget.chatUser.name!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(_currentUser.id, _otherUser.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data() as Chat?;
        List<ChatMessage> chatMessages = [];
        if (chat != null) {
          chatMessages = _generateChatMessages(chat.messages);
        }
        return DashChat(
          inputOptions: InputOptions(alwaysShowSend: true),
          messageOptions: MessageOptions(
            showTime: true,
            showOtherUsersAvatar: true,
          ),
          currentUser: _currentUser,
          onSend: _sendMessage,
          messages: chatMessages,
        );
      },
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    final message = Message(
      senderID: _currentUser.id,
      content: chatMessage.text,
      sentAt: Timestamp.fromDate(chatMessage.createdAt),
      messageType: MessageType.text,
    );
    await _databaseService.sendMessage(_currentUser.id, _otherUser.id, message);
  }

  List<ChatMessage> _generateChatMessages(List<Message> messages) {
    final chatMessages = messages.map((m) {
      return ChatMessage(
        text: m.content!,
        createdAt: m.sentAt!.toDate(),
        user: m.senderID == _currentUser.id ? _currentUser : _otherUser,
      );
    }).toList();
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }
}
