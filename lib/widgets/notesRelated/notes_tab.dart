import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notat/providers/search_provider.dart';
import 'package:notat/widgets/notesRelated/note_cards.dart';

class NotesTab extends ConsumerStatefulWidget {
  const NotesTab({super.key});

  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  final TextEditingController _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Scaffold(
        body: Column(
          children: [
            TextField(
              controller: _buscaController,
              onChanged: ref.read(buscaProvider.notifier).atualiza,
              style: GoogleFonts.roboto(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                hintText: 'Search notes',
                hintStyle: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.white38,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.white38,
                ),
                suffixIcon: _buscaController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white38,
                        ),
                        onPressed: () {
                          _buscaController.clear();
                          ref.read(buscaProvider.notifier).atualiza('');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(child: NoteCards(ref.watch(notasFiltradasProvider))),
          ],
        ),
      ),
    );
  }
}
