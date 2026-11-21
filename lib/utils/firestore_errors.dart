import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notat/utils/mensagem_de_erro.dart';

/// Adapter do Firestore para a [MensagemDeErro] do app.
///
/// Diferente do Auth, a mensagem do Firestore e sempre texto tecnico
/// (`Missing or insufficient permissions.`), entao ela nunca vai para a tela:
/// codigo desconhecido, ou erro que nem veio do Firebase, vira um aviso
/// generico.
class ErroDoFirestoreAdapter implements MensagemDeErro {
  const ErroDoFirestoreAdapter(this._erro);

  /// Object porque a falha de uma gravacao chega pelo catchError do Future,
  /// que nao garante o tipo.
  final Object _erro;

  static const generica = 'Something went wrong. Try again.';

  @override
  String get texto {
    final erro = _erro;
    if (erro is! FirebaseException) {
      return generica;
    }
    return switch (erro.code) {
      'permission-denied' => "You don't have permission to do this.",
      'unauthenticated' => 'Your session has expired. Sign in again.',
      'unavailable' ||
      'deadline-exceeded' => 'Could not reach the server. Try again later.',
      'not-found' => 'This item no longer exists.',
      'resource-exhausted' => 'Too many requests. Try again in a few minutes.',
      _ => generica,
    };
  }
}
