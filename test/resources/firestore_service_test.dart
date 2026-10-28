import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/resources/auth_methods.dart';
import 'package:notat/resources/firestore_methods.dart';
import 'package:notat/resources/firstore_folder_methods.dart';

import 'firestore_controlado.dart';

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
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 9, 3),
      );

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

    test(
      'editar a nota troca o folderId sem escrever em dois lugares',
      () async {
        await servico.addDocument(
          document: '[{"insert":"conteudo\\n"}]',
          title: 'Primeira',
          searchableDocument: 'conteudo',
          folder: 'All',
          date: DateTime(2026, 9, 3),
        );
        final noteUid = (await notas(db).get()).docs.single.id;

        await servico.updateDocument(
          document: '[{"insert":"novo\\n"}]',
          searchableDocument: 'novo',
          title: 'Editada',
          folder: 'Trabalho',
          noteUid: noteUid,
          date: DateTime(2026, 9, 4),
        );

        final salva = (await notas(db).doc(noteUid).get()).data()!;
        expect(salva['title'], 'Editada');
        expect(salva['folderId'], 'Trabalho');
      },
    );

    test(
      'o searchableDocument guarda o texto puro, sem escape de JSON',
      () async {
        await servico.addDocument(
          document: r'[{"insert":"Ela disse \"oi\"\nna reuniao\n"}]',
          title: 'Ata',
          searchableDocument: 'Ela disse "oi"\nna reuniao\n',
          date: DateTime(2026, 9, 5),
        );

        final salva = (await notas(db).get()).docs.single.data();
        expect(salva['searchableDocument'], 'ela disse "oi" na reuniao');
      },
    );

    test(
      'editar a nota normaliza o searchableDocument do mesmo jeito',
      () async {
        await servico.addDocument(
          document: '[{"insert":"antigo\\n"}]',
          title: 'Ata',
          searchableDocument: 'antigo',
          date: DateTime(2026, 9, 5),
        );
        final noteUid = (await notas(db).get()).docs.single.id;

        await servico.updateDocument(
          document: r'[{"insert":"Ela disse \"oi\"\nna reuniao\n"}]',
          searchableDocument: 'Ela disse "oi"\nna reuniao\n',
          title: 'Ata',
          folder: 'All',
          noteUid: noteUid,
          date: DateTime(2026, 9, 6),
        );

        final salva = (await notas(db).doc(noteUid).get()).data()!;
        expect(salva['searchableDocument'], 'ela disse "oi" na reuniao');
      },
    );

    test('criar a nota sem titulo grava untitled', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: '',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 10, 28),
      );

      final salva = (await notas(db).get()).docs.single.data();
      expect(salva['title'], 'untitled');
    });

    test('editar a nota apagando o titulo grava untitled', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Com titulo',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 10, 28),
      );
      final noteUid = (await notas(db).get()).docs.single.id;

      await servico.updateDocument(
        document: '[{"insert":"conteudo\\n"}]',
        searchableDocument: 'conteudo',
        title: '',
        folder: 'All',
        noteUid: noteUid,
        date: DateTime(2026, 10, 28, 12),
      );

      final salva = (await notas(db).doc(noteUid).get()).data()!;
      expect(salva['title'], 'untitled');
    });

    test('excluir a nota tira o documento da colecao', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Primeira',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 9, 3),
      );
      final noteUid = (await notas(db).get()).docs.single.id;

      await servico.deleteNote(uid: noteUid);

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

  group('sincronizacao offline', () {
    test('addDocument retorna sem esperar o servidor confirmar', () async {
      final semInternet = FirestoreControlado();

      await FirestoreService(semInternet, uid)
          .addDocument(
            document: '[{"insert":"conteudo\\n"}]',
            title: 'Offline',
            searchableDocument: 'conteudo',
            date: DateTime(2026, 10, 27),
          )
          .timeout(const Duration(seconds: 1));

      expect(semInternet.gravacoes, hasLength(1));
      expect(semInternet.gravacoes.single.isCompleted, isFalse);
    });

    test('updateDocument retorna sem esperar o servidor confirmar', () async {
      final semInternet = FirestoreControlado();

      await FirestoreService(semInternet, uid)
          .updateDocument(
            document: '[{"insert":"conteudo\\n"}]',
            searchableDocument: 'conteudo',
            title: 'Offline',
            folder: 'All',
            noteUid: 'nota-offline',
            date: DateTime(2026, 10, 27),
          )
          .timeout(const Duration(seconds: 1));

      expect(semInternet.gravacoes, hasLength(1));
      expect(semInternet.gravacoes.single.isCompleted, isFalse);
    });

    test('gravar a mesma nota duas vezes deixa um documento so', () async {
      await servico.addDocument(
        document: '[{"insert":"conteudo\\n"}]',
        title: 'Offline',
        searchableDocument: 'conteudo',
        date: DateTime(2026, 10, 27),
      );
      final salva = (await notas(db).get()).docs.single;

      // o reenvio da mesma gravacao, como o SDK faz quando a conexao volta
      for (var envio = 0; envio < 2; envio++) {
        await servico.updateDocument(
          document: salva.data()['document'] as String,
          searchableDocument: salva.data()['searchableDocument'] as String,
          title: salva.data()['title'] as String,
          folder: salva.data()['folderId'] as String,
          noteUid: salva.id,
          date: DateTime(2026, 10, 27),
        );
      }

      final salvas = await notas(db).get();
      expect(salvas.docs, hasLength(1));
      expect(
        salvas.docs.single.data()['document'],
        '[{"insert":"conteudo\\n"}]',
      );
    });

    test(
      'duas edicoes seguidas deixam um documento so, com a ultima versao',
      () async {
        await servico.addDocument(
          document: '[{"insert":"original\\n"}]',
          title: 'Original',
          searchableDocument: 'original',
          date: DateTime(2026, 10, 27),
        );
        final noteUid = (await notas(db).get()).docs.single.id;

        await servico.updateDocument(
          document: '[{"insert":"primeira edicao\\n"}]',
          searchableDocument: 'primeira edicao',
          title: 'Primeira edicao',
          folder: 'All',
          noteUid: noteUid,
          date: DateTime(2026, 10, 27, 10),
        );
        await servico.updateDocument(
          document: '[{"insert":"segunda edicao\\n"}]',
          searchableDocument: 'segunda edicao',
          title: 'Segunda edicao',
          folder: 'All',
          noteUid: noteUid,
          date: DateTime(2026, 10, 27, 11),
        );

        final salvas = await notas(db).get();
        expect(salvas.docs, hasLength(1));
        final salva = salvas.docs.single.data();
        expect(salva['title'], 'Segunda edicao');
        expect(salva['document'], '[{"insert":"segunda edicao\\n"}]');
      },
    );
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
