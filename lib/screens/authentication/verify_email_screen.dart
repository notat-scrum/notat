import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/screens/functionalities/home_page.dart';
import 'package:notat/widgets/reusedComponents/animation_transition.dart';
import 'package:notat/widgets/reusedComponents/sign_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

Future<dynamic> customBottomSheet(BuildContext context) {
  return showModalBottomSheet<dynamic>(
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(150)),
    ),
    context: context,
    builder: (BuildContext _) => const VerifyEmail(),
  );
}

class VerifyEmail extends ConsumerStatefulWidget {
  const VerifyEmail({super.key});

  @override
  ConsumerState<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends ConsumerState<VerifyEmail> {
  static const _duracaoInicial = Duration(minutes: 2);

  Duration _restante = _duracaoInicial;
  Timer? _contagem;
  bool isDismised = true;
  late Timer timer;

  void changeButtonState() {
    setState(() {
      isDismised = !isDismised;
    });
  }

  Future<void> checkVerification() async {
    final servico = ref.read(authServiceProvider);
    await servico.reloadUser();
    if (!mounted) return;
    if (servico.isVerified) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('Home page');
    }
  }

  Future<void> sendEmailVerification() async {
    final servico = ref.read(authServiceProvider);
    if (servico.isVerified) {
      Navigator.of(context)
          .pushReplacement(FadeTrans(translateTo: const HomePage()));
    } else {
      await servico.sendEmailVerification();
    }
  }

  void _iniciarContagem() {
    _contagem?.cancel();
    setState(() => _restante = _duracaoInicial);
    _contagem = Timer.periodic(const Duration(seconds: 1), (contagem) {
      if (_restante.inSeconds <= 1) {
        contagem.cancel();
        setState(() => _restante = Duration.zero);
        changeButtonState();
      } else {
        setState(() => _restante -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void initState() {
    sendEmailVerification();
    _iniciarContagem();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      checkVerification();
    });
    super.initState();
  }

  @override
  void dispose() {
    _contagem?.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
        ),
      ),
      alignment: Alignment.bottomCenter,
      child: Center(
        child: ListView(
          children: [
            const SizedBox(height: 50),
            Text(
              "Verify Email",
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LottieBuilder.network(
              'https://assets8.lottiefiles.com/packages/lf20_dd9wpbrh.json',
              height: 300,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.error_outline_outlined),
            ),
            Text(
              "We've sent you a verification email, Check your inbox/spam!",
              style: GoogleFonts.quicksand(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              height: 40,
              width: 200,
              child: CustomButton(
                backgroundColor: isDismised
                    ? Colors.white12
                    : Theme.of(context).primaryColor,
                labelColor: Colors.white,
                isRounded: true,
                isDisabled: isDismised,
                onTap: () async {
                  changeButtonState();
                  sendEmailVerification();
                  _iniciarContagem();
                },
                child: const Text("Resend Email"),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: Text(
                '${_restante.inMinutes.toString().padLeft(2, '0')}:'
                '${(_restante.inSeconds % 60).toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
