import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/models.dart';
import '../data/response_repository.dart';
import '../data/survey_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

final surveyRepositoryProvider = Provider<SurveyRepository>((ref) {
  return SurveyRepository(ref.watch(firestoreProvider));
});

final responseRepositoryProvider = Provider<ResponseRepository>((ref) {
  return ResponseRepository(ref.watch(firestoreProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final myProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final u = auth.currentUser;
  if (u == null) return const Stream.empty();
  return ref.watch(userRepositoryProvider).watchMyProfile(u.uid);
});

final myRoleProvider = Provider<UserRole?>((ref) {
  final prof = ref.watch(myProfileProvider).valueOrNull;
  return prof?.role;
});

final myNameProvider = Provider<String>((ref) {
  final prof = ref.watch(myProfileProvider).valueOrNull;
  return prof?.name ?? '';
});
