import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/resources/firestore_methods.dart';

import 'firestore_controlado.dart';

void main() {
  test('deleteNote retorna mensagem quando Firebase recusa exclusao', () async {
    final firestore = FirestoreControlado();
    final servico = FirestoreService(firestore, 'usuario-de-teste');

    final resultado = servico.deleteNote(uid: 'nota-de-teste');

    expect(firestore.exclusoes, hasLength(1));

    firestore.exclusoes.single.completeError(
      FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      ),
    );

    final erro = await resultado;

    expect(erro, 'Missing or insufficient permissions.');
  });

  test('deleteNote retorna null quando exclusao funciona', () async {
    final firestore = FirestoreControlado();
    final servico = FirestoreService(firestore, 'usuario-de-teste');

    final resultado = servico.deleteNote(uid: 'nota-de-teste');

    expect(firestore.exclusoes, hasLength(1));

    firestore.exclusoes.single.complete();

    expect(await resultado, isNull);
  });
}
