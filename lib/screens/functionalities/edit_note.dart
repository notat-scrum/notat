import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notat/models/note.dart';
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
  final ValueNotifier<String?> selected = ValueNotifier(null);
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  TextEditingController? _titleController;
  editor.QuillController? _controller;
  String? _notaCarregada;

  @override
  void dispose() {
    _controller?.dispose();
    _titleController?.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    selected.dispose();
    super.dispose();
  }

  // build roda de novo a cada emissao do provider; sem esta guarda cada rebuild
  // criava um par de controllers novo e vazava o anterior
  void _preparaControllers(Note nota) {
    if (_notaCarregada == nota.uid) {
      return;
    }
    _titleController?.dispose();
    _controller?.dispose();
    _titleController = TextEditingController(text: nota.title);
    _controller = editor.QuillController(
      document: editor.Document.fromJson(jsonDecode(nota.document)),
      selection: const TextSelection.collapsed(offset: 0),
    );
    selected.value = nota.folderId;
    _notaCarregada = nota.uid;
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
            _preparaControllers(nota);
            final controller = _controller!;
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
                                controller.document.toDelta().toJson(),
                              );
                              String plainText = controller.document
                                  .toPlainText();
                              final erro = await ref
                                  .read(firestoreServiceProvider)
                                  .updateDocument(
                                    folder: selected.value ?? nota.folderId,
                                    searchableDocument: plainText,
                                    document: json,
                                    title: _titleController!.text,
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
                            titleController: _titleController!,
                            selected: selected,
                            note: nota,
                          ),
                          SizedBox(height: 5),
                          Expanded(
                            child: editor.QuillEditor(
                              focusNode: _focusNode,
                              scrollController: _scrollController,
                              controller: controller,
                              config: editor.QuillEditorConfig(
                                scrollable: true,
                                autoFocus: false,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                expands: true,
                              ),
                            ),
                          ),
                          editor.QuillSimpleToolbar(
                            controller: controller,
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
