/// O que o app usa para mostrar um erro ao usuario, sem saber de onde ele veio.
///
/// E o alvo do padrao Adapter: cada origem de erro (Firebase Auth, Firestore)
/// tem um adapter que recebe o erro do SDK e o apresenta por esta interface.
/// Quem mostra a mensagem so depende daqui, e trocar o texto de uma origem nao
/// mexe nas outras.
abstract interface class MensagemDeErro {
  /// O texto que vai para a tela.
  String get texto;
}
