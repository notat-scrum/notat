import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  const Note({
    required this.uid,
    required this.title,
    required this.document,
    required this.searchableDocument,
    required this.folderId,
    required this.date,
  });

  /// O titulo de uma nota gravada sem titulo.
  static const tituloPadrao = 'untitled';

  /// Monta a nota como ela e gravada, a partir do que veio do editor. Criar e
  /// editar passam por aqui, para nao gravarem a nota de jeitos diferentes.
  factory Note.fromEditor({
    required String uid,
    required String title,
    required String document,
    required String plainText,
    required String folderId,
    required DateTime date,
  }) {
    return Note(
      uid: uid,
      title: title.isNotEmpty ? title : tituloPadrao,
      document: document,
      searchableDocument: plainText.toLowerCase().replaceAll('\n', ' ').trim(),
      folderId: folderId,
      date: date,
    );
  }

  factory Note.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data() ?? const <String, dynamic>{};
    return Note(
      uid: dados['uid'] as String? ?? doc.id,
      title: dados['title'] as String? ?? tituloPadrao,
      document: dados['document'] as String? ?? '',
      searchableDocument: dados['searchableDocument'] as String? ?? '',
      folderId: dados['folderId'] as String? ?? 'All',
      date: (dados['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String uid;
  final String title;
  final String document;
  final String searchableDocument;
  final String folderId;
  final DateTime date;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'title': title,
      'document': document,
      'searchableDocument': searchableDocument,
      'folderId': folderId,
      'date': Timestamp.fromDate(date),
    };
  }
}
