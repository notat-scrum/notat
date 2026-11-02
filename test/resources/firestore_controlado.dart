import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firestore em que o set() so termina quando o teste manda. Sem internet o SDK
/// de verdade se comporta assim: a escrita entra no cache local e o Future do
/// set() fica pendente ate o servidor responder, o que pode nunca acontecer.
class FirestoreControlado extends Fake implements FirebaseFirestore {
  /// Uma entrada por set() chamado, na ordem das chamadas.
  final List<Completer<void>> gravacoes = [];

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _Colecao(this);
}

// ignore: subtype_of_sealed_class
class _Colecao extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _Colecao(this._firestore);

  final FirestoreControlado _firestore;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _Documento(_firestore);
}

// ignore: subtype_of_sealed_class
class _Documento extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _Documento(this._firestore);

  final FirestoreControlado _firestore;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _Colecao(_firestore);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    final gravacao = Completer<void>();
    _firestore.gravacoes.add(gravacao);
    return gravacao.future;
  }
}
