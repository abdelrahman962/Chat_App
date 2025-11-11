import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? _user;
  User? get user => _user;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService() {
    _firebaseAuth.authStateChanges().listen(_authStateChangesStreamListener);
  }

  Future<bool> login(String email, String password) async {
    try {
      final account = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (account.user != null) {
        _user = account.user;
        return true;
      }
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
    return false;
  }

  void _authStateChangesStreamListener(User? user) {
    _user = user;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String email, String password) async {
    try {
      final account = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (account.user != null) {
        _user = account.user;
        return true;
      }
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
    return false;
  }
}
