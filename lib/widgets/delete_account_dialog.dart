import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/screens/authentication/introduction_screen.dart';
import 'package:notat/widgets/reusedComponents/animation_transition.dart';
import 'package:notat/widgets/reusedComponents/input_text_field.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final TextEditingController _controller = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);
    return AlertDialog(
      title: Text('Delete Account'),
      content: SizedBox(
        height: 140,
        child: Column(
          children: [
            Text('Are you sure you want to permanently delete your account?'),
            SizedBox(height: 20),
            Form(
              key: _key,
              child: InputTextField(
                autofocus: true,
                hintText: 'Confirm Password',
                isPassword: true,
                validator: (val) {
                  if (val != null && val.isNotEmpty) {
                    return null;
                  }
                  return 'Enter your password';
                },
                keyboardType: TextInputType.text,
                toNextField: false,
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_key.currentState!.validate() == true) {
              await auth.reloadUser();
              final erro = await auth.reauthentication(_controller.text);
              if (!context.mounted) return;
              if (erro != null) {
                CustomSnackBar.show(context, erro, Duration(seconds: 3));
              } else {
                await auth.deleteAccount();
                if (!context.mounted) return;
                FadeTrans(translateTo: IntroductionScreen());
              }
              Navigator.pop(context);
            }
          },
          child: Text('Delete Account', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
