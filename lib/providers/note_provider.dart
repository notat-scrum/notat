import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';

typedef NoteSnapshot = QuerySnapshot<Map<String, dynamic>>;

final notesProvider = StreamProvider<NoteSnapshot>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref
      .watch(firebaseFirestoreProvider)
      .collection(uid)
      .orderBy('date', descending: true)
      .snapshots();
});

final notesInFolderProvider = StreamProvider.family<NoteSnapshot, String>((
  ref,
  folder,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref
      .watch(firebaseFirestoreProvider)
      .collection(uid)
      .where('folder', isEqualTo: folder)
      .snapshots();
});

final noteProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, uid) => ref.watch(firestoreServiceProvider).getNote(uid: uid),
);
