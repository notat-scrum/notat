import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/resources/auth_methods.dart';
import 'package:notat/resources/firestore_methods.dart';
import 'package:notat/resources/firstore_folder_methods.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
  ),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).userChanges(),
);

/// Fonte unica do uid. Tudo que le o Firestore depende deste provider, entao o
/// logout derruba os listeners em vez de deixa-los abertos com o uid antigo.
final currentUidProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    throw StateError('FirestoreService lido sem usuario autenticado');
  }
  return FirestoreService(ref.watch(firebaseFirestoreProvider), uid);
});

final firestoreFolderServiceProvider = Provider<FirestoreFolderService>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    throw StateError('FirestoreFolderService lido sem usuario autenticado');
  }
  return FirestoreFolderService(ref.watch(firebaseFirestoreProvider), uid);
});
