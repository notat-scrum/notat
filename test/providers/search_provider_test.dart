import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/note_provider.dart';
import 'package:notat/providers/search_provider.dart';

Note nota(String title, String texto) => Note(
  uid: title,
  title: title,
  document: '[]',
  searchableDocument: texto,
  folderId: 'All',
  date: DateTime(2026, 9, 3),
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        notesProvider.overrideWith(
          (ref) => Stream.value([
            nota('Mercado', 'comprar leite e pao'),
            nota('Faculdade', 'entregar o trabalho de agil'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    // no Riverpod 3 todo provider e auto-dispose: sem um ouvinte vivo o stream
    // nunca chega a emitir
    container.listen(notasFiltradasProvider, (_, _) {});
  });

  Future<List<Note>> filtradas() async {
    await container.read(notesProvider.future);
    return container.read(notasFiltradasProvider).requireValue;
  }

  test('sem termo devolve todas as notas', () async {
    expect(await filtradas(), hasLength(2));
  });

  test('acha pelo conteudo, nao so pelo titulo', () async {
    container.read(buscaProvider.notifier).atualiza('leite');

    final resultado = await filtradas();
    expect(resultado, hasLength(1));
    expect(resultado.single.title, 'Mercado');
  });

  test('acha pelo titulo ignorando maiuscula', () async {
    container.read(buscaProvider.notifier).atualiza('FACULDADE');

    final resultado = await filtradas();
    expect(resultado.single.title, 'Faculdade');
  });

  test('termo sem correspondencia devolve lista vazia', () async {
    container.read(buscaProvider.notifier).atualiza('bicicleta');

    expect(await filtradas(), isEmpty);
  });
}
