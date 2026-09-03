import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/providers/note_provider.dart';
import 'package:notat/screens/errorAndLoading/error_screen.dart';
import 'package:notat/screens/errorAndLoading/loading_screen.dart';
import 'package:notat/widgets/notesRelated/custom_app_bar.dart';
import 'package:notat/widgets/notesRelated/note_header.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';
import 'package:flutter_quill/flutter_quill.dart' as editor;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditNote extends ConsumerStatefulWidget {
  final String noteUid;
  const EditNote({super.key, required this.noteUid});

  @override
  EditNoteState createState() => EditNoteState();
}

class EditNoteState extends ConsumerState<EditNote> {
  ValueNotifier<String?> selected = ValueNotifier(null);
  late TextEditingController _titleController;
  late editor.QuillController _controller;
  bool showEditor = false;

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(noteProvider(widget.noteUid))
        .when(
          error: ((error, stackTrace) => ErrorPage()),
          loading: (() => LoadingScreen()),
          data: ((nota) {
            if (nota == null) return ErrorPage();
            _titleController = TextEditingController(text: nota.title);
            selected.value = nota.folderId;
            final previousFolder = nota.folderId;
            _controller = editor.QuillController(
              document: editor.Document.fromJson(jsonDecode(nota.document)),
              selection: const TextSelection.collapsed(offset: 0),
            );
            return SafeArea(
              child: Scaffold(
                body: CustomScrollView(
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
                                  .updateDocument(
                                    previousFolder: previousFolder,
                                    folder: selected.value,
                                    searchableDocument: plainText,
                                    document: json,
                                    title: _titleController.text,
                                    noteUid: widget.noteUid,
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
                              Navigator.of(context).pop();
                            },
                          ),
                          NoteHeader(
                            editNoteMod: true,
                            titleController: _titleController,
                            selected: selected,
                            note: nota,
                          ),
                          SizedBox(height: 5),
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
          }),
        );
  }
}
