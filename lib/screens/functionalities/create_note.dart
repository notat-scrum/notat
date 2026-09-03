import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/widgets/notesRelated/custom_app_bar.dart';
import 'package:notat/widgets/notesRelated/note_header.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';
import 'package:flutter_quill/flutter_quill.dart' as editor;

class CreateNote extends ConsumerStatefulWidget {
  const CreateNote({super.key});

  @override
  ConsumerState<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends ConsumerState<CreateNote> {
  final editor.QuillController _controller = editor.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  ValueNotifier<String> selected = ValueNotifier('All');

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  CustomAppBar(
                    onPressed: () async {
                      String json = jsonEncode(
                        _controller.document.toDelta().toJson(),
                      );
                      String plainText = jsonEncode(
                        _controller.document.toPlainText(),
                      );
                      final erro = await ref
                          .read(firestoreServiceProvider)
                          .addDocument(
                            document: json,
                            searchableDocument: plainText,
                            title: _titleController.text,
                            folder: selected.value,
                            date: DateTime.now(),
                          );
                      if (!context.mounted) return;
                      if (erro != null) {
                        CustomSnackBar.show(
                          context,
                          erro,
                          Duration(seconds: 2),
                        );
                      }
                      Navigator.pop(context);
                    },
                  ),
                  NoteHeader(
                    editNoteMod: false,
                    titleController: _titleController,
                    selected: selected,
                    note: null,
                  ),
                  Expanded(
                    child: editor.QuillEditor(
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                      controller: _controller,
                      config: editor.QuillEditorConfig(
                        scrollable: true,
                        autoFocus: false,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        expands: true,
                      ),
                    ),
                  ),
                  editor.QuillSimpleToolbar(
                    controller: _controller,
                    config: editor.QuillSimpleToolbarConfig(
                      color: Theme.of(context).cardColor,
                      multiRowsDisplay: false,
                      showIndent: true,
                      dialogTheme: editor.QuillDialogTheme(
                        inputTextStyle: TextStyle(color: Colors.white),
                        labelTextStyle: TextStyle(color: Colors.white),
                      ),
                      showLink: true,
                      showDirection: false,
                      showBackgroundColorButton: false,
                      showRedo: true,
                      showSearchButton: true,
                      showFontSize: false,
                      showAlignmentButtons: true,
                      showCodeBlock: true,
                      showFontFamily: false,
                      showInlineCode: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
