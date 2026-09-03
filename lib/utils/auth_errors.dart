import 'package:firebase_auth/firebase_auth.dart';

/// Traduz o erro do Firebase Auth. O codigo e estavel entre versoes do SDK, a
/// mensagem nao, entao a traducao olha o codigo e so cai na mensagem original
/// quando encontra um codigo que ainda nao conhece.
String traduzErroDeAuth(FirebaseException erro) {
  switch (erro.code) {
    case 'email-already-in-use':
      return 'Este e-mail já está cadastrado.';
    case 'invalid-email':
      return 'E-mail inválido.';
    case 'weak-password':
      return 'Senha fraca. Use ao menos seis caracteres.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'too-many-requests':
      return 'Muitas tentativas. Tente de novo em alguns minutos.';
    case 'network-request-failed':
      return 'Sem conexão com a internet.';
    case 'requires-recent-login':
      return 'Entre de novo na conta antes de repetir esta ação.';
    case 'operation-not-allowed':
      return 'Esta forma de login está desativada no projeto.';
    default:
      return erro.message ?? 'Não foi possível concluir a operação.';
  }
}
