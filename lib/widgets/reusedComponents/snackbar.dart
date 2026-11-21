import 'package:flutter/material.dart';

class CustomSnackBar {
  final String message;
  final Duration duration;
  CustomSnackBar({required this.message, required this.duration});

  static void show(BuildContext context, String message, Duration duration) =>
      preparar(context, duration)(message);

  /// Guarda agora o que o aviso precisa do [context] e devolve quem o mostra
  /// depois. Serve para avisar o resultado de um await mesmo que o widget
  /// tenha saido da tela enquanto esperava.
  static void Function(String message) preparar(
    BuildContext context,
    Duration duration,
  ) {
    final mensageiro = ScaffoldMessenger.of(context);
    final fundo = Theme.of(context).cardColor;
    return (message) => mensageiro.showSnackBar(
      SnackBar(
        backgroundColor: fundo,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Text(message),
      ),
    );
  }
}
