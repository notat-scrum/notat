import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/folders_provider.dart';
import 'package:notat/resources/user_collections.dart';
import 'package:notat/screens/functionalities/edit_note.dart';
import 'package:notat/widgets/notesRelated/note_cards.dart';

const uid = 'usuario-de-teste';

void main() {
  late FakeFirebaseFirestore db;

  final nota = Note(
    uid: 'nota-de-teste',
    title: 'Minha nota',
    document: '[{"insert":"Conteudo de teste\\n"}]',
    searchableDocument: 'conteudo de teste',
    folderId: 'All',
    date: DateTime(2026, 11, 2),
  );

  setUp(() {
    db = FakeFirebaseFirestore();
  });

  Future<void> mostraCard(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(db),
          currentUidProvider.overrideWithValue(uid),
          folderProvider.overrideWithValue(const AsyncData(['All'])),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          home: Scaffold(
            body: Center(
              child: SizedBox(width: 180, height: 250, child: NoteCard(nota)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> seguraCard(WidgetTester tester) async {
    await tester.longPress(find.text('Minha nota'));
    await tester.pumpAndSettle();
  }

  testWidgets('segurar o card abre o menu sem erro de ScrollController', (
    tester,
  ) async {
    await mostraCard(tester);

    await seguraCard(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Delete do menu apaga a nota', (tester) async {
    await db.notesOf(uid).doc(nota.uid).set(nota.toFirestore());
    await mostraCard(tester);

    await seguraCard(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect((await db.notesOf(uid).doc(nota.uid).get()).exists, isFalse);
  });

  testWidgets('Edit do menu abre a edicao da nota', (tester) async {
    await db.notesOf(uid).doc(nota.uid).set(nota.toFirestore());
    await mostraCard(tester);

    await seguraCard(tester);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final edicao = tester.widget<EditNote>(find.byType(EditNote));
    expect(edicao.noteUid, nota.uid);
  });
}
