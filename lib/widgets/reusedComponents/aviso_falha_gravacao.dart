import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/falha_gravacao_provider.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';

/// Fica acima de todas as rotas, no builder do MaterialApp, para avisar a falha
/// da gravacao mesmo depois que a tela da nota ja saiu da pilha.
class AvisoFalhaGravacao extends ConsumerWidget {
  const AvisoFalhaGravacao({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(falhaGravacaoProvider, (_, falha) {
      if (falha != null) {
        CustomSnackBar.show(context, falha.mensagem, Duration(seconds: 4));
      }
    });
    return child;
  }
}
