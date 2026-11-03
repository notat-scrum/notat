import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/folders_provider.dart';
import 'package:notat/widgets/foldersRelated/folders._tab.dart';

import '../resources/firestore_controlado.dart';

void main() {
  testWidgets('mostra erro quando exclusao da pasta falha', (tester) async {
    final firestore = FirestoreControlado();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          currentUidProvider.overrideWithValue('usuario-de-teste'),
          folderProvider.overrideWith(
            (ref) => Stream.value(['Pasta de teste']),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: FoldersTab())),
      ),
    );

    await tester.pump();

    final menu = tester.widget<FocusedMenuHolder>(
      find.byType(FocusedMenuHolder),
    );

    final opcaoExcluir = menu.menuItems.firstWhere(
      (item) =>
          item.title is Text &&
          (item.title as Text).data == 'Delete (All notes inside)',
    );

    opcaoExcluir.onPressed();

    await tester.pump();

    expect(find.text('Missing or insufficient permissions.'), findsOneWidget);
  });
}
