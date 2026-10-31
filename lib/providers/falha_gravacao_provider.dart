import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uma gravacao de nota que o servidor recusou. Cada falha e uma instancia
/// nova, entao duas falhas com a mesma mensagem avisam duas vezes.
class FalhaGravacao {
  const FalhaGravacao(this.mensagem);

  final String mensagem;
}

/// A gravacao so falha quando o servidor responde, e isso pode acontecer muito
/// depois de a tela da nota fechar. Por isso a falha vai para este provider, que
/// o app inteiro escuta, e nao para a tela que pediu a gravacao.
class FalhaGravacaoNotifier extends Notifier<FalhaGravacao?> {
  @override
  FalhaGravacao? build() => null;

  void avisa(String mensagem) => state = FalhaGravacao(mensagem);
}

final falhaGravacaoProvider =
    NotifierProvider<FalhaGravacaoNotifier, FalhaGravacao?>(
      FalhaGravacaoNotifier.new,
    );
