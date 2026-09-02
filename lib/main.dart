import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notat/screens/authentication/login_screen.dart';
import 'package:notat/screens/errorAndLoading/error_screen.dart';
import 'package:notat/screens/authentication/signup_screen.dart';
import 'package:notat/screens/functionalities/home_page.dart';
import 'package:notat/screens/wrapper.dart';
import 'package:notat/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ErrorWidget.builder = (details) => const ErrorPage();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.darkTheme,
      home: const Wrapper(),
      routes: {
        'Login': (context) => const LoginScreen(),
        'Sign up': (context) => const SignUpScreen(),
        'Home page': (context) => const HomePage(),
      },
    );
  }
}
