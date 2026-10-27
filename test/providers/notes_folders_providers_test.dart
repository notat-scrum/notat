import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/folders_provider.dart';
import 'package:notat/providers/note_provider.dart';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
  });

  ProviderContainer criarContainer({required String? uid}) {
    final container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(db),
        currentUidProvider.overrideWithValue(uid),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  // Todo provider e auto-dispose no Riverpod 3. O listen mantem o provider
  // vivo enquanto o teste le o primeiro valor do stream.
  Future<T> ler<T>(ProviderContainer container, StreamProvider<T> provider) {
    container.listen(provider, (anterior, atual) {});
    return container.read(provider.future);
  }

  Future<void> criarNota(
    String uid,
    String id, {
    required String titulo,
    required DateTime data,
    String pasta = 'All',
  }) {
    return db.collection('users').doc(uid).collection('notes').doc(id).set({
      'title': titulo,
      'document': '[{"insert":"conteudo\\n"}]',
      'searchableDocument': 'conteudo',
      'folderId': pasta,
      'date': Timestamp.fromDate(data),
    });
  }

  Future<void> criarPasta(String uid, String nome, DateTime criadaEm) {
    return db.collection('users').doc(uid).collection('folders').doc(nome).set({
      'name': nome,
      'createdAt': Timestamp.fromDate(criadaEm),
    });
  }

  group('deslogado', () {
    test(
      'notesProvider devolve lista vazia em vez de ficar carregando',
      () async {
        final container = criarContainer(uid: null);

        final notas = await ler<List<Note>>(container, notesProvider);

        expect(notas, isEmpty);
      },
    );

    test(
      'notesInFolderProvider devolve lista vazia em vez de ficar carregando',
      () async {
        final container = criarContainer(uid: null);

        final notas = await ler<List<Note>>(
          container,
          notesInFolderProvider('Trabalho'),
        );

        expect(notas, isEmpty);
      },
    );

    test(
      'folderProvider devolve lista vazia em vez de ficar carregando',
      () async {
        final container = criarContainer(uid: null);

        final pastas = await ler<List<String>>(container, folderProvider);

        expect(pastas, isEmpty);
      },
    );
  });

  group('notesProvider', () {
    test('traz as notas do usuario da mais nova para a mais antiga', () async {
      await criarNota('u1', 'a', titulo: 'Antiga', data: DateTime(2026, 9, 1));
      await criarNota('u1', 'b', titulo: 'Nova', data: DateTime(2026, 9, 3));
      await criarNota('u1', 'c', titulo: 'Meio', data: DateTime(2026, 9, 2));
      final container = criarContainer(uid: 'u1');

      final notas = await ler<List<Note>>(container, notesProvider);

      expect(notas.map((n) => n.title), ['Nova', 'Meio', 'Antiga']);
    });

    test('nao traz as notas de outro uid', () async {
      await criarNota('u1', 'a', titulo: 'Minha', data: DateTime(2026, 9, 1));
      await criarNota(
        'u2',
        'b',
        titulo: 'De outro',
        data: DateTime(2026, 9, 2),
      );
      final container = criarContainer(uid: 'u1');

      final notas = await ler<List<Note>>(container, notesProvider);

      expect(notas.map((n) => n.title), ['Minha']);
    });
  });

  group('notesInFolderProvider', () {
    test('traz so as notas da pasta pedida', () async {
      await criarNota(
        'u1',
        'a',
        titulo: 'Dentro',
        data: DateTime(2026, 9, 1),
        pasta: 'Trabalho',
      );
      await criarNota(
        'u1',
        'b',
        titulo: 'Fora',
        data: DateTime(2026, 9, 2),
        pasta: 'Estudos',
      );
      await criarNota(
        'u1',
        'c',
        titulo: 'Sem pasta',
        data: DateTime(2026, 9, 3),
      );
      final container = criarContainer(uid: 'u1');

      final notas = await ler<List<Note>>(
        container,
        notesInFolderProvider('Trabalho'),
      );

      expect(notas.map((n) => n.title), ['Dentro']);
    });
  });

  group('folderProvider', () {
    test('traz as pastas na ordem de criacao', () async {
      await criarPasta('u1', 'Segunda', DateTime(2026, 9, 2));
      await criarPasta('u1', 'Terceira', DateTime(2026, 9, 3));
      await criarPasta('u1', 'Primeira', DateTime(2026, 9, 1));
      final container = criarContainer(uid: 'u1');

      final pastas = await ler<List<String>>(container, folderProvider);

      expect(pastas, ['Primeira', 'Segunda', 'Terceira']);
    });

    test('nao traz as pastas de outro uid', () async {
      await criarPasta('u1', 'Minha', DateTime(2026, 9, 1));
      await criarPasta('u2', 'De outro', DateTime(2026, 9, 2));
      final container = criarContainer(uid: 'u1');

      final pastas = await ler<List<String>>(container, folderProvider);

      expect(pastas, ['Minha']);
    });
  });
}
