import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_app/utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late final AuthService _authService;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  DatabaseService() {
    _authService = GetIt.instance<AuthService>();
    _setupCollections();
  }
  void _setupCollections() {
    _usersCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(
          fromFirestore: (snapShot, _) =>
              UserProfile.fromJson(snapShot.data()!),
          toFirestore: (userProfile, _) => userProfile.toJson(),
        );
    _chatsCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(
          fromFirestore: (snapShot, _) => Chat.fromJson(snapShot.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfile() {
    return _usersCollection
            ?.where("uid", isNotEqualTo: _authService.user?.uid)
            .snapshots()
        as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatId(uid1, uid2);
    final docSnapshot = await _chatsCollection!.doc(chatId).get();
    return docSnapshot.exists;
  }

  Future<void> createChat(String uid1, String uid2) async {
    String chatId = generateChatId(uid1, uid2);
    final chatDoc = _chatsCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);

    await chatDoc.set(chat);
  }

  Future<void> sendMessage(String uid1, String uid2, Message message) async {
    String chatId = generateChatId(uid1, uid2);
    final chatDoc = _chatsCollection!.doc(chatId);
    await chatDoc.update({
      'messages': FieldValue.arrayUnion([message.toJson()]),
    });
  }

  Stream<DocumentSnapshot<Object?>>? getChatData(String uid1, String uid2) {
    String chatId = generateChatId(uid1, uid2);
    return _chatsCollection?.doc(chatId).snapshots();
  }

  Future<void> markMessagesAsRead(
    String uid1,
    String uid2,
    String currentUserId,
  ) async {
    String chatId = generateChatId(uid1, uid2);
    final chatDoc = await _chatsCollection!.doc(chatId).get();

    if (chatDoc.exists) {
      final chat = chatDoc.data() as Chat;
      final updatedMessages = chat.messages.map((message) {
        if (message.senderID != currentUserId && message.isRead == false) {
          return Message(
            senderID: message.senderID,
            content: message.content,
            messageType: message.messageType,
            sentAt: message.sentAt,
            isRead: true,
            readAt: Timestamp.now(),
          );
        }
        return message;
      }).toList();

      await _chatsCollection!.doc(chatId).update({
        'messages': updatedMessages.map((m) => m.toJson()).toList(),
      });
    }
  }
}
