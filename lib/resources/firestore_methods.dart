import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notat/models/note.dart';
import 'package:notat/resources/firstore_folder_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  FirestoreService(this._firestore, this.userUid)
    : firestoreFolder = FirestoreFolderService(_firestore, userUid);

  final FirebaseFirestore _firestore;
  final FirestoreFolderService firestoreFolder;
  final String userUid;

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.collection('users').doc(userUid).collection('notes');

  Future<String?> addDocument({
    required String document,
    required String title,
    required String searchableDocument,
    String folder = 'All',
    required DateTime date,
  }) async {
    final String uid = const Uuid().v4();
    final Note note = Note(
      folderId: folder,
      document: document,
      searchableDocument: searchableDocument
          .toLowerCase()
          .replaceAll('\n', ' ')
          .trim(),
      date: date,
      uid: uid,
      title: title.isNotEmpty ? title : 'untitled',
    );

    try {
      // o set() so completa quando o servidor confirma; sem internet ele fica
      // pendente para sempre e a tela travaria. O SDK ja guarda a escrita
      // localmente e sincroniza sozinho quando a conexao volta.
      unawaited(_notes.doc(uid).set(note.toFirestore()));
    } on FirebaseException catch (e) {
      return e.message!;
    }
    return null;
  }

  Future<String?> updateDocument({
    required String document,
    required String searchableDocument,
    required String title,
    required String folder,
    required String noteUid,
    required DateTime date,
  }) async {
    final Note note = Note(
      folderId: folder,
      searchableDocument: searchableDocument
          .toLowerCase()
          .replaceAll('\n', ' ')
          .trim(),
      document: document,
      date: date,
      uid: noteUid,
      title: title.isNotEmpty ? title : 'untitled',
    );

    try {
      unawaited(_notes.doc(noteUid).set(note.toFirestore()));
    } on FirebaseException catch (e) {
      return e.message!;
    }
    return null;
  }

  Future<Note?> getNote({required String uid}) async {
    final snapshot = await _notes.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return Note.fromFirestore(snapshot);
  }

  Future<String?> clearAllNotes() async {
    try {
      QuerySnapshot<Map<String, dynamic>> documentos;
      try {
        documentos = await _notes.get(const GetOptions(source: Source.cache));
      } catch (_) {
        documentos = await _notes.get();
      }
      await _apagaEmLote(documentos);
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<String?> deleteDocsOfFolder(String folder) async {
    try {
      QuerySnapshot<Map<String, dynamic>> documentos;
      try {
        documentos = await _notes
            .where('folderId', isEqualTo: folder)
            .get(const GetOptions(source: Source.cache));
      } catch (_) {
        documentos = await _notes.where('folderId', isEqualTo: folder).get();
      }
      await _apagaEmLote(documentos);
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<String?> deleteNote({required String uid}) async {
    try {
      await _notes.doc(uid).delete();
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<String?> deleteAllDocs() async {
    try {
      QuerySnapshot<Map<String, dynamic>> notasDocs;
      QuerySnapshot<Map<String, dynamic>> pastasDocs;
      try {
        notasDocs = await _notes.get(const GetOptions(source: Source.cache));
      } catch (_) {
        notasDocs = await _notes.get();
      }
      try {
        pastasDocs = await firestoreFolder.folders.get(
          const GetOptions(source: Source.cache),
        );
      } catch (_) {
        pastasDocs = await firestoreFolder.folders.get();
      }

      final lote = _firestore.batch();
      for (final doc in notasDocs.docs) {
        lote.delete(doc.reference);
      }
      for (final doc in pastasDocs.docs) {
        lote.delete(doc.reference);
      }
      await lote.commit();
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<void> _apagaEmLote(QuerySnapshot<Map<String, dynamic>> documentos) {
    if (documentos.docs.isEmpty) {
      return Future.value();
    }
    final lote = _firestore.batch();
    for (final documento in documentos.docs) {
      lote.delete(documento.reference);
    }
    return lote.commit();
  }
}
