import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:notat/firebase_options.dart';
import 'package:notat/screens/authentication/login_screen.dart';
import 'package:notat/screens/authentication/signup_screen.dart';
import 'package:notat/screens/functionalities/home_page.dart';
import 'package:notat/screens/wrapper.dart';
import 'package:notat/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const bool _usarEmulador = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

// Visto de dentro do emulador Android, a maquina do desenvolvedor e 10.0.2.2.
// Em aparelho fisico, passe o IP da maquina na rede local.
const String _hostEmulador = String.fromEnvironment(
  'FIREBASE_EMULATOR_HOST',
  defaultValue: '10.0.2.2',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_usarEmulador) {
    await FirebaseAuth.instance.useAuthEmulator(_hostEmulador, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(_hostEmulador, 8080);
  }
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const Material(
      color: Color.fromRGBO(31, 29, 43, 1),
      child: Center(
        child: Icon(Icons.error_outline_outlined, color: Colors.white70),
      ),
    );
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
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
