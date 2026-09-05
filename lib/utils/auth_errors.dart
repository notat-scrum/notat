import 'package:firebase_auth/firebase_auth.dart';

/// Traduz o erro do Firebase Auth. O codigo e estavel entre versoes do SDK, a
/// mensagem nao, entao a traducao olha o codigo e so cai na mensagem original
/// quando encontra um codigo que ainda nao conhece.
String traduzErroDeAuth(FirebaseException erro) {
  switch (erro.code) {
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'weak-password':
      return 'Weak password. Use at least six characters.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Wrong email or password.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Try again in a few minutes.';
    case 'network-request-failed':
      return 'No internet connection.';
    case 'requires-recent-login':
      return 'Sign in again before repeating this action.';
    case 'operation-not-allowed':
      return 'This sign-in method is disabled for this project.';
    default:
      return erro.message ?? 'Could not complete the operation.';
  }
}
