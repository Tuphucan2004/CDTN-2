import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // REGISTER
  Future<User?> register(String email, String password) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return null;
    }
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await auth.signOut();
  }
}