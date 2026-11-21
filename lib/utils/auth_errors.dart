import 'package:firebase_auth/firebase_auth.dart';
import 'package:notat/utils/mensagem_de_erro.dart';

/// Adapter do Firebase Auth para a [MensagemDeErro] do app.
///
/// O codigo e estavel entre versoes do SDK, a mensagem nao, entao a traducao
/// olha o codigo e so cai na mensagem original quando encontra um codigo que
/// ainda nao conhece.
class ErroDoAuthAdapter implements MensagemDeErro {
  const ErroDoAuthAdapter(this._erro);

  final FirebaseException _erro;

  @override
  String get texto => switch (_erro.code) {
    'email-already-in-use' => 'This email is already registered.',
    'invalid-email' => 'Invalid email address.',
    'weak-password' => 'Weak password. Use at least six characters.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Wrong email or password.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many attempts. Try again in a few minutes.',
    'network-request-failed' => 'No internet connection.',
    'requires-recent-login' => 'Sign in again before repeating this action.',
    'operation-not-allowed' =>
      'This sign-in method is disabled for this project.',
    _ => _erro.message ?? 'Could not complete the operation.',
  };
}

/// Atalho para o texto do [ErroDoAuthAdapter].
String traduzErroDeAuth(FirebaseException erro) =>
    ErroDoAuthAdapter(erro).texto;
