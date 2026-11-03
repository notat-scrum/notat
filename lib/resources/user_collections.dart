import 'package:cloud_firestore/cloud_firestore.dart';

/// Unico lugar que sabe onde ficam as colecoes de um usuario no Firestore.
extension UserCollections on FirebaseFirestore {
  CollectionReference<Map<String, dynamic>> notesOf(String uid) =>
      collection('users').doc(uid).collection('notes');

  CollectionReference<Map<String, dynamic>> foldersOf(String uid) =>
      collection('users').doc(uid).collection('folders');
}
