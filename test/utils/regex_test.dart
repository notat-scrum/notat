import 'package:flutter_test/flutter_test.dart';
import 'package:notat/utils/regex.dart';

void main() {
  group('emailRegExp', () {
    test('aceita endereços válidos', () {
      expect(emailRegExp.hasMatch('vini@example.com'), isTrue);
      expect(emailRegExp.hasMatch('a.b-c@sub.dominio.com.br'), isTrue);
    });

    test('recusa endereços sem arroba ou sem domínio', () {
      expect(emailRegExp.hasMatch('sem-arroba.com'), isFalse);
      expect(emailRegExp.hasMatch('vini@'), isFalse);
      expect(emailRegExp.hasMatch('vini@dominio'), isFalse);
    });

    test('recusa endereço com espaço', () {
      expect(emailRegExp.hasMatch('vi ni@example.com'), isFalse);
    });
  });

  group('passwordRegExp', () {
    test('aceita senha com maiúscula, minúscula, dígito e símbolo', () {
      expect(passwordRegExp.hasMatch('Senha1!'), isTrue);
    });

    test('recusa senha sem maiúscula', () {
      expect(passwordRegExp.hasMatch('senha1!'), isFalse);
    });

    test('recusa senha sem dígito', () {
      expect(passwordRegExp.hasMatch('Senha!!'), isFalse);
    });

    test('recusa senha sem símbolo', () {
      expect(passwordRegExp.hasMatch('Senha11'), isFalse);
    });
  });
}
