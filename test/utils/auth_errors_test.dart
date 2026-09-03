import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/utils/auth_errors.dart';

void main() {
  test('traduz o codigo do Firebase para a mensagem do app', () {
    final erro = FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'The email address is already in use by another account.',
    );

    expect(traduzErroDeAuth(erro), 'This email is already registered.');
  });

  test('nao vaza a diferenca entre e-mail e senha errados', () {
    final semUsuario = FirebaseAuthException(code: 'user-not-found');
    final senhaErrada = FirebaseAuthException(code: 'wrong-password');

    expect(traduzErroDeAuth(semUsuario), traduzErroDeAuth(senhaErrada));
  });

  test('cai na mensagem original quando o codigo e desconhecido', () {
    final erro = FirebaseAuthException(
      code: 'codigo-que-nao-existe',
      message: 'Something went wrong.',
    );

    expect(traduzErroDeAuth(erro), 'Something went wrong.');
  });
}
