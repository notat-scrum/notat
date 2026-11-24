import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/utils/auth_errors.dart';
import 'package:notat/utils/firestore_errors.dart';
import 'package:notat/utils/mensagem_de_erro.dart';

void main() {
  test('o app le o erro das duas origens pela mesma interface', () {
    final List<MensagemDeErro> mensagens = [
      ErroDoAuthAdapter(FirebaseAuthException(code: 'wrong-password')),
      ErroDoFirestoreAdapter(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
    ];

    expect(mensagens.map((mensagem) => mensagem.texto), [
      'Wrong email or password.',
      "You don't have permission to do this.",
    ]);
  });

  test('traduzErroDeAuth devolve o texto do adapter do Auth', () {
    final erro = FirebaseAuthException(code: 'too-many-requests');

    expect(traduzErroDeAuth(erro), ErroDoAuthAdapter(erro).texto);
  });
}
