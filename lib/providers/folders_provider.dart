import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';

final folderProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>>((
  ref,
) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    return const Stream.empty();
  }
  return ref
      .watch(firebaseFirestoreProvider)
      .collection(uid)
      .doc('folders')
      .snapshots();
});
