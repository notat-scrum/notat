import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:notat/models/note.dart';
import 'package:notat/providers/auth_provider.dart';
import 'package:notat/screens/errorAndLoading/empty_result.dart';
import 'package:notat/screens/errorAndLoading/error_screen.dart';
import 'package:notat/screens/errorAndLoading/loading_screen.dart';
import 'package:notat/screens/functionalities/edit_note.dart';
import 'package:notat/widgets/reusedComponents/animation_transition.dart';
import 'package:notat/widgets/reusedComponents/snackbar.dart';

class NoteCards extends StatelessWidget {
  final AsyncValue<List<Note>> snapshot;

  const NoteCards(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return snapshot.when(
      data: ((notas) {
        if (notas.isEmpty) {
          return EmptyResult();
        }

        return MasonryGridView.builder(
          physics: const BouncingScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
          itemCount: notas.length,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: ((context, index) => NoteCard(notas[index])),
        );
      }),
      error: ((error, stackTrace) => ErrorPage()),
      loading: (() => const LoadingScreen()),
    );
  }
}

class NoteCard extends ConsumerWidget {
  const NoteCard(this.nota, {super.key});

  final Note nota;

  void _abreEdicao(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(FadeTrans(translateTo: EditNote(noteUid: nota.uid)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FocusedMenuHolder(
      menuWidth: 200,
      menuOffset: 10,
      bottomOffsetHeight: 0,
      menuBoxDecoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      animateMenuItems: false,
      blurBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onPressed: () => _abreEdicao(context),
      menuItems: [
        FocusedMenuItem(
          trailingIcon: const Icon(
            Icons.edit,
            color: Color.fromARGB(178, 255, 255, 255),
          ),
          title: const Text('Edit'),
          onPressed: () => _abreEdicao(context),
          backgroundColor: const Color.fromARGB(255, 57, 55, 78),
        ),
        FocusedMenuItem(
          trailingIcon: const Icon(
            Icons.delete_forever_outlined,
            color: Colors.white,
          ),
          title: const Text('Delete'),
          onPressed: () async {
            // o Firestore tira a nota do cache local antes de o servidor
            // responder, e o card sai da tela; o aviso e preparado antes do
            // await para a recusa ainda chegar ao usuario
            final avisa = CustomSnackBar.preparar(
              context,
              const Duration(seconds: 3),
            );
            final erro = await ref
                .read(firestoreServiceProvider)
                .deleteNote(uid: nota.uid);

            if (erro != null) {
              avisa(erro);
            }
          },
          backgroundColor: Colors.redAccent,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 22),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            AutoSizeText(
              nota.title,
              minFontSize: 16,
              maxLines: 4,
              textAlign: TextAlign.left,
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            ShaderMask(
              shaderCallback: ((bounds) {
                return const LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(189, 218, 218, 252),
                    Color.fromARGB(189, 218, 218, 252),
                    Colors.transparent,
                  ],
                ).createShader(bounds);
              }),
              child: _PreviaDaNota(nota.document),
            ),
            Row(
              children: [
                Text(
                  Jiffy.parseFromDateTime(nota.date).MMMd,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: const Color.fromARGB(90, 255, 255, 255),
                  ),
                ),
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 85,
                  child: Text(
                    nota.folderId,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: const Color.fromARGB(90, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// O FocusedMenuHolder desenha o card duas vezes (lista e menu); cada copia
/// precisa do proprio ScrollController, por isso eles vivem aqui e nao no card.
class _PreviaDaNota extends StatefulWidget {
  const _PreviaDaNota(this.document);

  final String document;

  @override
  State<_PreviaDaNota> createState() => _PreviaDaNotaState();
}

class _PreviaDaNotaState extends State<_PreviaDaNota> {
  late quill.QuillController _controller;
  final ScrollController _scrollController = ScrollController(
    keepScrollOffset: false,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = _criaController();
  }

  @override
  void didUpdateWidget(_PreviaDaNota oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _controller.dispose();
      _controller = _criaController();
    }
  }

  quill.QuillController _criaController() => quill.QuillController(
    document: quill.Document.fromJson(jsonDecode(widget.document)),
    selection: const TextSelection.collapsed(offset: 0),
    readOnly: true,
  );

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return quill.QuillEditor(
      scrollController: _scrollController,
      controller: _controller,
      focusNode: _focusNode,
      config: const quill.QuillEditorConfig(
        padding: EdgeInsets.only(bottom: 10),
        // a previa e so leitura; com foco automatico, o card que
        // sai da tela leva junto um FocusNode ainda focado
        autoFocus: false,
        enableInteractiveSelection: false,
        showCursor: false,
        scrollPhysics: NeverScrollableScrollPhysics(),
        scrollable: true,
        expands: false,
        maxHeight: 150,
      ),
    );
  }
}
