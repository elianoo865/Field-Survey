import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository(this._auth, this._db);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ensureProfile(cred.user);
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'role': 'surveyor',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateMyName({required String uid, required String name}) async {
    await _db.collection('users').doc(uid).set({'name': name}, SetOptions(merge: true));
  }

  Future<void> _ensureProfile(User? user) async {
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': user.email ?? '',
        'role': 'surveyor',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

class UserRepository {
  final FirebaseFirestore _db;
  UserRepository(this._db);

  Stream<UserProfile> watchMyProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((d) => UserProfile.fromDoc(d));
  }

  Stream<List<UserProfile>> watchAllUsers() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots().map((qs) {
      return qs.docs.map(UserProfile.fromDoc).toList();
    });
  }

  Future<void> setRole({required String uid, required UserRole role}) async {
    await _db.collection('users').doc(uid).set({'role': roleToString(role)}, SetOptions(merge: true));
  }

  Future<void> setActive({required String uid, required bool isActive}) async {
    await _db.collection('users').doc(uid).set({'isActive': isActive}, SetOptions(merge: true));
  }
}
