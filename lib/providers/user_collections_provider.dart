import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/resources/user_collections.dart';

typedef UserDoc = QueryDocumentSnapshot<Map<String, dynamic>>;
typedef UserCollection = CollectionReference<Map<String, dynamic>>;
typedef UserQuery = Query<Map<String, dynamic>>;

/// Acompanha uma consulta sobre as notas do usuario logado.
Stream<List<T>> watchUserNotes<T>(
  Ref ref,
  UserQuery Function(UserCollection notes) query,
  T Function(UserDoc doc) convert,
) => _watch(ref, (db, uid) => query(db.notesOf(uid)), convert);

/// Acompanha uma consulta sobre as pastas do usuario logado.
Stream<List<T>> watchUserFolders<T>(
  Ref ref,
  UserQuery Function(UserCollection folders) query,
  T Function(UserDoc doc) convert,
) => _watch(ref, (db, uid) => query(db.foldersOf(uid)), convert);

Stream<List<T>> _watch<T>(
  Ref ref,
  UserQuery Function(FirebaseFirestore db, String uid) query,
  T Function(UserDoc doc) convert,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    // deslogado nao e carregando: Stream.empty nunca emite e a tela ficaria
    // presa no indicador de progresso
    return Stream.value(<T>[]);
  }
  return query(
    ref.watch(firebaseFirestoreProvider),
    uid,
  ).snapshots().map((consulta) => consulta.docs.map(convert).toList());
}
