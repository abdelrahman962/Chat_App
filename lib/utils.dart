import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:get_it/get_it.dart';

Future<void> setupFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

Future<void> registerServices() async {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerSingleton<AuthService>(AuthService());
  }

  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerSingleton<NotificationService>(NotificationService());
  }
  if (!getIt.isRegistered<DatabaseService>()) {
    getIt.registerSingleton<DatabaseService>(DatabaseService());
  }
}

String generateChatId(String uid1, String uid2) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatId = uids.fold('', (id, uid) => "$id$uid");
  return chatId;
}
