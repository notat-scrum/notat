import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/widgets/notesRelated/note_cards.dart';

import '../resources/firestore_controlado.dart';

void main() {
  late FirestoreControlado firestore;

  setUp(() {
    firestore = FirestoreControlado();
  });

  Future<void> abreNota(WidgetTester tester) async {
    final nota = Note(
      uid: 'nota-de-teste',
      title: 'Minha nota',
      document: '[{"insert":"Conteudo de teste\\n"}]',
      searchableDocument: 'conteudo de teste',
      folderId: 'All',
      date: DateTime(2026, 11, 2),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          currentUidProvider.overrideWithValue('usuario-de-teste'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 180, height: 250, child: NoteCard(nota)),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra erro quando exclusao da nota falha', (tester) async {
    await abreNota(tester);

    // Localiza o menu da nota sem precisar abri-lo visualmente.
    final menu = tester.widget<FocusedMenuHolder>(
      find.byType(FocusedMenuHolder),
    );

    // Encontra a opcao Delete.
    final opcaoExcluir = menu.menuItems.firstWhere(
      (item) => item.title is Text && (item.title as Text).data == 'Delete',
    );

    // Executa a acao de exclusao.
    opcaoExcluir.onPressed();

    await tester.pump();

    // Confirma que a exclusao foi solicitada.
    expect(firestore.exclusoes, hasLength(1));

    // Simula uma falha de permissao do Firebase.
    firestore.exclusoes.single.completeError(
      FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions.',
      ),
    );

    // Aguarda o processamento da resposta e a exibicao do SnackBar.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verifica se a mensagem de erro apareceu na tela.
    expect(find.text('Missing or insufficient permissions.'), findsOneWidget);
  });
}
