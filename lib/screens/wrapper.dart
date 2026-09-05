import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/screens/authentication/introduction_screen.dart';
import 'package:notat/screens/errorAndLoading/error_screen.dart';
import 'package:notat/screens/errorAndLoading/loading_screen.dart';
import 'package:notat/screens/functionalities/home_page.dart';

class Wrapper extends ConsumerWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authStateProvider)
        .when(
          data: (usuario) {
            if (usuario != null && usuario.emailVerified) {
              return const HomePage();
            }
            return const IntroductionScreen();
          },
          loading: () => const LoadingScreen(),
          error: (erro, stackTrace) => ErrorPage(),
        );
  }
}
