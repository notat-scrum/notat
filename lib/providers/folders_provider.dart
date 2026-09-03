import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';

/// Os nomes das pastas do usuario. O id de cada documento e o proprio nome, que
/// e o que a nota guarda em folderId.
final folderProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref
      .watch(firebaseFirestoreProvider)
      .collection('users')
      .doc(uid)
      .collection('folders')
      .orderBy('createdAt')
      .snapshots()
      .map((consulta) => consulta.docs.map((doc) => doc.id).toList());
});
