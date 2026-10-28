import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/widgets/reusedComponents/aviso_falha_gravacao.dart';

import '../resources/firestore_controlado.dart';

const uid = 'usuario-de-teste';

final recusa = FirebaseException(
  plugin: 'cloud_firestore',
  code: 'permission-denied',
  message: 'Missing or insufficient permissions.',
);

void main() {
  late FirestoreControlado firestore;
  late ProviderContainer container;

  setUp(() {
    firestore = FirestoreControlado();
    container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        currentUidProvider.overrideWithValue(uid),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> abreOApp(WidgetTester tester) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        builder: (context, child) => AvisoFalhaGravacao(child: child!),
        home: const Scaffold(body: Text('Lista de notas')),
      ),
    ),
  );

  Future<void> abreEFechaATelaDaNota(
    WidgetTester tester,
    Future<void> Function() salva,
  ) async {
    final navegador = tester.state<NavigatorState>(find.byType(Navigator));
    navegador.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Tela da nota')),
      ),
    );
    await tester.pumpAndSettle();
    await salva();
    navegador.pop();
    await tester.pumpAndSettle();
    expect(find.text('Tela da nota'), findsNothing);
  }

  testWidgets(
    'a falha ao criar a nota chega ao usuario depois que a tela fechou',
    (tester) async {
      await abreOApp(tester);
      await abreEFechaATelaDaNota(
        tester,
        () => container
            .read(firestoreServiceProvider)
            .addDocument(
              document: '[{"insert":"conteudo\\n"}]',
              title: 'Recusada',
              searchableDocument: 'conteudo',
              date: DateTime(2026, 10, 27),
            ),
      );

      firestore.gravacoes.single.completeError(recusa);
      await tester.pumpAndSettle();

      expect(find.textContaining(recusa.message!), findsOneWidget);
    },
  );

  testWidgets(
    'a falha ao editar a nota chega ao usuario depois que a tela fechou',
    (tester) async {
      await abreOApp(tester);
      await abreEFechaATelaDaNota(
        tester,
        () => container
            .read(firestoreServiceProvider)
            .updateDocument(
              document: '[{"insert":"conteudo\\n"}]',
              searchableDocument: 'conteudo',
              title: 'Recusada',
              folder: 'All',
              noteUid: 'nota-recusada',
              date: DateTime(2026, 10, 27),
            ),
      );

      firestore.gravacoes.single.completeError(recusa);
      await tester.pumpAndSettle();

      expect(find.textContaining(recusa.message!), findsOneWidget);
    },
  );
}
