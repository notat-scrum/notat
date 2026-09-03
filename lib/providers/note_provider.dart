import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notat/resources/auth_methods.dart';
import 'package:notat/resources/firestore_methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notesProvider = StreamProvider(
  (ref) => FirebaseFirestore.instance
      .collection(AuthService().useUid)
      .orderBy('date', descending: true)
      .snapshots(),
);

final notesInFolderProvider =
    StreamProvider.family<QuerySnapshot<Map<String, dynamic>>, String>(
      (ref, folder) => FirebaseFirestore.instance
          .collection(AuthService().useUid)
          .where('folder', isEqualTo: folder)
          .snapshots(),
    );

final noteProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, uid) => FirestoreService().getNote(uid: uid),
);
