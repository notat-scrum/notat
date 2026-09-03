import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/resources/auth_methods.dart';
import 'package:notat/resources/firestore_methods.dart';
import 'package:notat/resources/firstore_folder_methods.dart';

const uid = 'usuario-de-teste';

// Contrato alvo da #25: as notas e as pastas vivem embaixo de users/{uid} e a
// pasta de uma nota e so o campo folderId. Estes testes descrevem esse contrato,
// nao o esquema que o app grava hoje.
CollectionReference<Map<String, dynamic>> notas(FirebaseFirestore db) =>
    db.collection('users').doc(uid).collection('notes');

CollectionReference<Map<String, dynamic>> pastas(FirebaseFirestore db) =>
    db.collection('users').doc(uid).collection('folders');

void main() {
  late FakeFirebaseFirestore db;
  late FirestoreService servico;
  late FirestoreFolderService servicoPastas;

  setUp(() {
    db = FakeFirebaseFirestore();
    servico = FirestoreService(db, uid);
    servicoPastas = FirestoreFolderService(db, uid);
  });

  group('notas', () {
    test('cria a nota em users/{uid}/notes', () async {
      final erro = await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 9, 3),
      );

      expect(erro, isNull);
      final salvas = await notas(db).get();
      expect(salvas.docs, hasLength(1));
      expect(salvas.docs.single.data()['title'], 'Primeira');
    });

    test('a pasta da nota vive so no campo folderId', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        folder: 'Trabalho',
        date: DateTime(2026, 9, 3),
      );

      final salva = (await notas(db).get()).docs.single.data();
      expect(salva['folderId'], 'Trabalho');
      expect(salva.containsKey('folder'), isFalse);
    });

    test('editar a nota troca o folderId sem escrever em dois lugares', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        folder: 'All',
        date: DateTime(2026, 9, 3),
      );
      final noteUid = (await notas(db).get()).docs.single.id;

      final erro = await servico.updateDocument(
        document: '[{"insert":"novo\\n"}]',
        searchableDocument: 'novo',
        title: 'Editada',
        previousFolder: 'All',
        folder: 'Trabalho',
        noteUid: noteUid,
        date: DateTime(2026, 9, 4),
      );

      expect(erro, isNull);
      final salva = (await notas(db).doc(noteUid).get()).data()!;
      expect(salva['title'], 'Editada');
      expect(salva['folderId'], 'Trabalho');
    });

    test('excluir a nota tira o documento da colecao', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 9, 3),
      );
      final noteUid = (await notas(db).get()).docs.single.id;

      await servico.deleteNote(uid: noteUid, folder: 'All');

      expect((await notas(db).get()).docs, isEmpty);
    });

    test('limpar as notas preserva as pastas', () async {
      await servicoPastas.createFolder('Trabalho');
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        folder: 'Trabalho',
        date: DateTime(2026, 9, 3),
      );

      await servico.clearAllNotes();

      expect((await notas(db).get()).docs, isEmpty);
      expect((await pastas(db).get()).docs, isNotEmpty);
    });
  });

  group('pastas', () {
    test('cria a pasta como documento em users/{uid}/folders', () async {
      final erro = await servicoPastas.createFolder('Trabalho');

      expect(erro, isNull);
      final salvas = await pastas(db).get();
      expect(salvas.docs, hasLength(1));
      expect(salvas.docs.single.data()['name'], 'Trabalho');
    });

    test('excluir a pasta leva junto as notas de dentro', () async {
      await servicoPastas.createFolder('Trabalho');
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Dentro',
        searchableDocument: 'conteudo',
        folder: 'Trabalho',
        date: DateTime(2026, 9, 3),
      );
      await servico.addDocument(
        document: '[{"insert":"outro\\n"}]',
        title: 'Fora',
        searchableDocument: 'outro',
        date: DateTime(2026, 9, 3),
      );

      await servicoPastas.deleteFolder('Trabalho');

      expect((await pastas(db).get()).docs, isEmpty);
      final restantes = await notas(db).get();
      expect(restantes.docs, hasLength(1));
      expect(restantes.docs.single.data()['title'], 'Fora');
    });
  });

  group('exclusao de conta', () {
    test('deleteAllDocs limpa notas e pastas do usuario', () async {
      await servicoPastas.createFolder('Trabalho');
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 9, 3),
      );

      await servico.deleteAllDocs();

      expect((await notas(db).get()).docs, isEmpty);
      expect((await pastas(db).get()).docs, isEmpty);
    });

    test('criar a conta ja deixa a pasta All pronta', () async {
      final auth = MockFirebaseAuth();
      final servicoAuth = AuthService(auth, db);

      await servicoAuth.createUser(
        email: 'teste@notat.app',
        password: 'Senha!123',
      );

      final novoUid = auth.currentUser!.uid;
      final criadas = await db
          .collection('users')
          .doc(novoUid)
          .collection('folders')
          .get();
      expect(criadas.docs.map((d) => d.data()['name']), contains('All'));
    });
  });
}
