import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/folders_provider.dart';
import 'package:notat/resources/user_collections.dart';
import 'package:notat/screens/functionalities/create_note.dart';

const uid = 'usuario-de-teste';

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
  });

  Future<void> abreNovaNota(WidgetTester tester) async {
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
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CreateNote()),
                  ),
                  child: const Text('lista de notas'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('lista de notas'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateNote), findsOneWidget);
  }

  for (final intervalo in const [0, 50, 100, 200]) {
    testWidgets('dois toques no Save com $intervalo ms entre eles gravam uma '
        'nota so e voltam para a lista', (tester) async {
      await abreNovaNota(tester);
      await tester.enterText(find.byType(TextFormField), 'Lista de compras');

      final save = find.text('Save');
      await tester.tap(save);
      await tester.pump(Duration(milliseconds: intervalo));
      await tester.tap(save, warnIfMissed: false);
      await tester.pumpAndSettle();

      final notas = await db.notesOf(uid).get();
      expect(notas.docs, hasLength(1));
      expect(notas.docs.single.data()['title'], 'Lista de compras');
      expect(find.byType(CreateNote), findsNothing);
      expect(find.text('lista de notas'), findsOneWidget);
    });
  }
}
