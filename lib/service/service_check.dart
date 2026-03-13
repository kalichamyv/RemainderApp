import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// MAINLY USER TO CHECK LOGIN AND LOGOUT

class AuthService {
  /// CONNECTING THE FIRE BASE AND auth IS USED FOR (LOGIN LOGOUT CURRENT USER) firestore (USER NAME EMAIL PASSWORD)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String phoneno,
  }) async {
    /// REQUEST TO FIREBASE SERVICE TO CREATE A NEW USER AND GENERATE A NEW UID FOR THE USER
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    ///EXTRACT THE UID OF THE USER
    String uid = userCredential.user!.uid;
    /// THIS CREATE THE DOCUMENT IN THE FIRE BASE AND STORE THE FOLLOWING DATA
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'password': password,
      'email': email,
      'phone': phoneno,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LOGIN
  /// IT CHECK THE USER IS AN EXISTING OR NEW USER
  Future<void> login({required String email, required String password}) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;
}
