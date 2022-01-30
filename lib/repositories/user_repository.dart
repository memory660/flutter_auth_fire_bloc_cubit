import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> register(String email, String password) async {
    final user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user;
  }

  Future<UserCredential> login(String email, String password) async {
    final user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> isSignIn() async {
    final user = await _auth.currentUser;
    return user != null;
  }

  Future<void> signInGoogle() async {}

  Future<User> getUser() async {
    final user = await _auth.currentUser!;
    print(user);
    return user;
  }
}
