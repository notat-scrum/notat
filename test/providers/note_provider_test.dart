import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/note_provider.dart';
import 'package:notat/resources/firestore_methods.dart';

const uid = 'usuario-de-teste';

void main() {
  late FakeFirebaseFirestore db;
  late ProviderContainer container;
  late FirestoreService servico;

  setUp(() {
    db = FakeFirebaseFirestore();
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(db),
        currentUidProvider.overrideWithValue(uid),
      ],
    );
    addTearDown(container.dispose);
    servico = container.read(firestoreServiceProvider);
  });

  Future<String> criaNota(String titulo) async {
    await servico.addDocument(
      document: '[{"insert":"$titulo\\n"}]',
      title: titulo,
      searchableDocument: titulo,
      date: DateTime(2026, 10, 27),
    );
    return (await db.collection('users').doc(uid).collection('notes').get())
        .docs
        .single
        .id;
  }

  Future<void> salvaVersao(String noteUid, String titulo) =>
      servico.updateDocument(
        document: '[{"insert":"$titulo\\n"}]',
        searchableDocument: titulo,
        title: titulo,
        folder: 'All',
        noteUid: noteUid,
        date: DateTime(2026, 10, 27, 12),
      );

  /// A tela de edicao escuta o provider enquanto esta aberta e solta quando
  /// fecha.
  Future<Note?> abreATelaDeEdicao(String noteUid) async {
    final tela = container.listen(noteProvider(noteUid), (_, _) {});
    addTearDown(tela.close);
    final nota = await container.read(noteProvider(noteUid).future);
    tela.close();
    await container.pump();
    return nota;
  }

  test('abrir a nota traz o conteudo salvo', () async {
    final noteUid = await criaNota('Primeira');

    final nota = await abreATelaDeEdicao(noteUid);

    expect(nota!.title, 'Primeira');
  });

  test(
    'reabrir a nota depois de salvar uma versao nova traz a versao nova',
    () async {
      final noteUid = await criaNota('Primeira');
      await abreATelaDeEdicao(noteUid);

      await salvaVersao(noteUid, 'Editada');
      final reaberta = await abreATelaDeEdicao(noteUid);

      expect(reaberta!.title, 'Editada');
      expect(reaberta.document, '[{"insert":"Editada\\n"}]');
    },
  );

  test('abrir uma nota que nao existe devolve null', () async {
    expect(await abreATelaDeEdicao('nota-que-nao-existe'), isNull);
  });
}
