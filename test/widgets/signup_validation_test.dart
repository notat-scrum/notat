import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notat/screens/authentication/signup_screen.dart';

const senhaFraca = 'Weak password, try add a special character/letter/number';
const senhasDiferentes = "Password Confirmation isn't correct";

void main() {
  Future<void> preencheEValida(
    WidgetTester tester, {
    required String senha,
    required String confirmacao,
  }) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: SignUpDetails())),
      ),
    );

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'pessoa@exemplo.com');
    await tester.enterText(campos.at(1), senha);
    await tester.enterText(campos.at(2), confirmacao);

    // valida direto pelo Form: o botao Sign up chamaria o Firebase quando o
    // formulario passa, e o que interessa aqui e so o texto dos campos
    tester.state<FormState>(find.byType(Form)).validate();
    await tester.pump();
  }

  testWidgets('senha fraca avisa so no campo de senha', (tester) async {
    await preencheEValida(tester, senha: 'fraca', confirmacao: 'fraca');

    expect(find.text(senhaFraca), findsOneWidget);
    expect(find.text(senhasDiferentes), findsNothing);
  });

  testWidgets('confirmacao diferente avisa so que as senhas nao batem', (
    tester,
  ) async {
    await preencheEValida(tester, senha: 'Forte@123', confirmacao: 'Outra@123');

    expect(find.text(senhasDiferentes), findsOneWidget);
    expect(find.text(senhaFraca), findsNothing);
  });

  testWidgets('senha forte e confirmacao igual nao mostram aviso', (
    tester,
  ) async {
    await preencheEValida(tester, senha: 'Forte@123', confirmacao: 'Forte@123');

    expect(find.text(senhaFraca), findsNothing);
    expect(find.text(senhasDiferentes), findsNothing);
  });
}
