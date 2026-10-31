import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notat/models/note.dart';
import 'package:notat/resources/firstore_folder_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  FirestoreService(this._firestore, this.userUid, {this.aoFalharGravacao})
    : firestoreFolder = FirestoreFolderService(_firestore, userUid);

  final FirebaseFirestore _firestore;
  final FirestoreFolderService firestoreFolder;
  final String userUid;

  /// Recebe a mensagem quando o servidor recusa a gravacao de uma nota. Sem ele
  /// a falha nao e engolida: segue como erro nao tratado.
  final void Function(String mensagem)? aoFalharGravacao;

  CollectionReference<Map<String, dynamic>> get _notes =>
      _firestore.collection('users').doc(userUid).collection('notes');

  Future<void> addDocument({
    required String document,
    required String title,
    required String searchableDocument,
    String folder = 'All',
    required DateTime date,
  }) async {
    _gravaSemEsperar(
      Note.fromEditor(
        uid: const Uuid().v4(),
        title: title,
        document: document,
        plainText: searchableDocument,
        folderId: folder,
        date: date,
      ),
    );
  }

  Future<void> updateDocument({
    required String document,
    required String searchableDocument,
    required String title,
    required String folder,
    required String noteUid,
    required DateTime date,
  }) async {
    _gravaSemEsperar(
      Note.fromEditor(
        uid: noteUid,
        title: title,
        document: document,
        plainText: searchableDocument,
        folderId: folder,
        date: date,
      ),
    );
  }

  // o set() so completa quando o servidor confirma; sem internet ele fica
  // pendente para sempre e a tela travaria. O SDK ja guarda a escrita
  // localmente e sincroniza sozinho quando a conexao volta. Um try/catch em
  // volta nao pegaria nada, porque o erro chega depois que o metodo retornou:
  // a falha tem que ser tratada no proprio Future.
  void _gravaSemEsperar(Note note) {
    final gravacao = _notes.doc(note.uid).set(note.toFirestore());
    final aviso = aoFalharGravacao;
    if (aviso == null) {
      unawaited(gravacao);
      return;
    }
    unawaited(
      gravacao.catchError(
        (Object erro) => aviso('The note could not be saved: ${_motivo(erro)}'),
      ),
    );
  }

  static String _motivo(Object erro) =>
      erro is FirebaseException ? erro.message ?? erro.code : erro.toString();

  /// Emite primeiro o que esta no cache local, entao abre na hora mesmo sem
  /// internet, e de novo a cada gravacao da nota.
  Stream<Note?> watchNote({required String uid}) => _notes
      .doc(uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? Note.fromFirestore(snapshot) : null);

  Future<String?> clearAllNotes() async {
    try {
      final documentos = await _notes.get(
        const GetOptions(source: Source.cache),
      );
      await _apagaEmLote(documentos);
    } on FirebaseException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<String?> deleteDocsOfFolder(String folder) async {
    try {
      final documentos = await _notes
          .where('folderId', isEqualTo: folder)
          .get(const GetOptions(source: Source.cache));
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
      await _apagaEmLote(await _notes.get());
      await _apagaEmLote(await firestoreFolder.folders.get());
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
