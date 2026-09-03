import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/note_provider.dart';

class BuscaNotifier extends Notifier<String> {
  @override
  String build() => '';

  void atualiza(String termo) => state = termo.trim().toLowerCase();
}

final buscaProvider = NotifierProvider<BuscaNotifier, String>(
  BuscaNotifier.new,
);

/// Busca sobre a lista que ja esta em memoria. O Firestore nao faz busca em
/// texto, e o volume de notas de um usuario cabe no cliente.
final notasFiltradasProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final termo = ref.watch(buscaProvider);
  final notas = ref.watch(notesProvider);
  if (termo.isEmpty) {
    return notas;
  }
  return notas.whenData(
    (lista) => lista
        .where(
          (nota) =>
              nota.title.toLowerCase().contains(termo) ||
              nota.searchableDocument.contains(termo),
        )
        .toList(),
  );
});
