import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String phoneno,
  }) async {
    UserCredential userCredential =
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'username':username,
      'email': email,
      'phone': phoneno,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LOGIN
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;
}