import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';

final notesProvider = StreamProvider<List<Note>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    // deslogado nao e carregando: Stream.empty nunca emite e a tela ficaria
    // presa no indicador de progresso
    return Stream.value(const <Note>[]);
  }
  return ref
      .watch(firebaseFirestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('notes')
      .orderBy('date', descending: true)
      .snapshots()
      .map((consulta) => consulta.docs.map(Note.fromFirestore).toList());
});

final notesInFolderProvider = StreamProvider.family<List<Note>, String>((
  ref,
  folder,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    // deslogado nao e carregando: Stream.empty nunca emite e a tela ficaria
    // presa no indicador de progresso
    return Stream.value(const <Note>[]);
  }
  return ref
      .watch(firebaseFirestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('notes')
      .where('folderId', isEqualTo: folder)
      .snapshots()
      .map((consulta) => consulta.docs.map(Note.fromFirestore).toList());
});

final noteProvider = FutureProvider.family<Note?, String>(
  (ref, uid) => ref.watch(firestoreServiceProvider).getNote(uid: uid),
);
