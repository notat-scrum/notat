import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/folders_provider.dart';
import 'package:notat/providers/note_provider.dart';
import 'package:notat/screens/functionalities/home_page.dart';

import '../resources/firestore_controlado.dart';

void main() {
  testWidgets('mostra erro quando Clear All notes falha', (tester) async {
    final firestore = FirestoreControlado();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          currentUidProvider.overrideWithValue('usuario-de-teste'),
          notesProvider.overrideWith((ref) => Stream.value([])),
          folderProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp(
          theme: ThemeData(
            tabBarTheme: const TabBarThemeData(labelColor: Colors.blue),
          ),
          home: const HomePage(),
        ),
      ),
    );

    await tester.pump();

    // Abre o menu da tela inicial.
    await tester.tap(find.byIcon(Icons.more_horiz_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Seleciona a opcao de excluir todas as notas.
    await tester.tap(find.text('Clear All notes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verifica se o erro retornado pelo Firebase aparece.
    expect(find.text('Missing or insufficient permissions.'), findsOneWidget);
  });
}
