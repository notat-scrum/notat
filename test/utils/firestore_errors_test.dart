import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/utils/firestore_errors.dart';

FirebaseException erroDoFirestore(String code) => FirebaseException(
  plugin: 'cloud_firestore',
  code: code,
  message: 'Texto tecnico do SDK para $code.',
);

void main() {
  test('traduz a recusa das regras para a mensagem do app', () {
    final adapter = ErroDoFirestoreAdapter(
      erroDoFirestore('permission-denied'),
    );

    expect(adapter.texto, "You don't have permission to do this.");
  });

  test('servidor fora do ar e tempo esgotado dao a mesma mensagem', () {
    final foraDoAr = ErroDoFirestoreAdapter(erroDoFirestore('unavailable'));
    final tempoEsgotado = ErroDoFirestoreAdapter(
      erroDoFirestore('deadline-exceeded'),
    );

    expect(foraDoAr.texto, tempoEsgotado.texto);
  });

  test('codigo desconhecido vira a mensagem generica, sem o texto do SDK', () {
    final erro = erroDoFirestore('codigo-que-nao-existe');

    final texto = ErroDoFirestoreAdapter(erro).texto;

    expect(texto, ErroDoFirestoreAdapter.generica);
    expect(texto, isNot(contains(erro.message!)));
  });

  test('erro que nao veio do Firebase vira a mensagem generica', () {
    final adapter = ErroDoFirestoreAdapter(StateError('falha interna'));

    expect(adapter.texto, ErroDoFirestoreAdapter.generica);
  });

  test('nenhum codigo conhecido devolve o texto tecnico do SDK', () {
    const codigos = [
      'permission-denied',
      'unauthenticated',
      'unavailable',
      'deadline-exceeded',
      'not-found',
      'resource-exhausted',
    ];

    for (final codigo in codigos) {
      final erro = erroDoFirestore(codigo);
      expect(
        ErroDoFirestoreAdapter(erro).texto,
        isNot(erro.message),
        reason: codigo,
      );
    }
  });
}
