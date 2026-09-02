import 'package:flutter/material.dart';
import 'package:notat/resources/firstore_folder_methods.dart';
import 'package:notat/widgets/reusedComponents/input_text_field.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class FolderDialog extends StatelessWidget {
  const FolderDialog({
    super.key,
    required this.formKey,
    required this.folderController,
    required this.keys,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController folderController;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            folderController.clear();
          },
          child: Text('Cancel', style: GoogleFonts.ubuntu(color: Colors.red)),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate() == true) {
              final erro = await FirestoreFolderService().createFolder(
                folderController.text,
              );
              if (!context.mounted) return;
              if (erro != null) {
                CustomSnackBar.show(context, erro, Duration(seconds: 2));
              }
            }
            Navigator.of(context).pop();
            folderController.clear();
          },
          child: Text(
            'Add',
            style: GoogleFonts.ubuntu(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'Create a folder',
        style: GoogleFonts.ubuntu(color: Colors.white),
      ),
      content: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: InputTextField(
          autofocus: true,
          hintText: 'Folder Name',
          isPassword: false,
          validator: (val) {
            if (!(keys.contains(val)) && (val != null && val.isNotEmpty)) {
              return null;
            }
            return 'Find another name';
          },
          keyboardType: TextInputType.text,
          toNextField: false,
          maxLength: 25,
          controller: folderController,
        ),
      ),
    );
  }
}
