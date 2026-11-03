import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firestore em que as operacoes so terminam quando o teste manda.
/// Isso permite simular sucesso, falha e operacoes pendentes.
class FirestoreControlado extends Fake implements FirebaseFirestore {
  /// Uma entrada por set() chamado, na ordem das chamadas.
  final List<Completer<void>> gravacoes = [];

  /// Uma entrada por delete() chamado, na ordem das chamadas.
  final List<Completer<void>> exclusoes = [];

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
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'Missing or insufficient permissions.',
    );
  }

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'Missing or insufficient permissions.',
    );
  }

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

  @override
  Future<void> delete() {
    final exclusao = Completer<void>();
    _firestore.exclusoes.add(exclusao);
    return exclusao.future;
  }
}
